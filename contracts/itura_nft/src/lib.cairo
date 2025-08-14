#[feature("deprecated_legacy_map")]
#[starknet::contract]
mod IturaNFT {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // Ownable Mixin  
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        // Custom storage
        token_counter: u256,
        therapeutic_data: LegacyMap<u256, TherapeuticData>,
        community_contributions: LegacyMap<u256, u32>,
        base_uri: ByteArray,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct TherapeuticData {
        therapeutic_milestone: u32,
        session_data_hash: felt252,
        is_collaborative: bool,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        TherapeuticNFTMinted: TherapeuticNFTMinted,
        MilestoneUpdated: MilestoneUpdated,
        CommunityContributionSet: CommunityContributionSet,
    }

    #[derive(Drop, starknet::Event)]
    struct TherapeuticNFTMinted {
        #[key]
        token_id: u256,
        #[key]
        owner: ContractAddress,
        therapeutic_milestone: u32,
        session_data_hash: felt252,
        is_collaborative: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct MilestoneUpdated {
        #[key]
        token_id: u256,
        old_milestone: u32,
        new_milestone: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CommunityContributionSet {
        #[key]
        token_id: u256,
        percentage: u32,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        owner: ContractAddress
    ) {
        self.erc721.initializer(name, symbol, base_uri.clone());
        self.ownable.initializer(owner);
        self.base_uri.write(base_uri);
        self.token_counter.write(0);
    }

    #[abi(embed_v0)]
    impl IIturaNFT of super::IIturaNFT<ContractState> {
        fn mint_therapeutic_nft(
            ref self: ContractState,
            to: ContractAddress,
            therapeutic_milestone: u32,
            session_data_hash: felt252,
            is_collaborative: bool
        ) -> u256 {
            // Only owner can mint
            self.ownable.assert_only_owner();
            
            let current_token_id = self.token_counter.read();
            let token_id = current_token_id + 1;
            
            // Store therapeutic data
            let therapeutic_data = TherapeuticData {
                therapeutic_milestone,
                session_data_hash,
                is_collaborative
            };
            self.therapeutic_data.write(token_id, therapeutic_data);
            
            // Mint the NFT using internal trait
            self.erc721.mint(to, token_id);
            
            // Update counter
            self.token_counter.write(token_id);
            
            // Emit event
            self.emit(TherapeuticNFTMinted {
                token_id,
                owner: to,
                therapeutic_milestone,
                session_data_hash,
                is_collaborative
            });
            
            token_id
        }

        fn get_therapeutic_data(self: @ContractState, token_id: u256) -> (u32, felt252, bool) {
            // Use the token_uri method to check if token exists (will panic if not)
            let _ = self.erc721.token_uri(token_id);
            let data = self.therapeutic_data.read(token_id);
            (data.therapeutic_milestone, data.session_data_hash, data.is_collaborative)
        }

        fn update_milestone(
            ref self: ContractState,
            token_id: u256,
            new_milestone: u32
        ) {
            // Check if token exists
            let _ = self.erc721.token_uri(token_id);
            
            // Only token owner can update milestone
            let token_owner = self.erc721.owner_of(token_id);
            assert(get_caller_address() == token_owner, 'Not token owner');
            
            let data = self.therapeutic_data.read(token_id);
            let old_milestone = data.therapeutic_milestone;
            let new_data = TherapeuticData {
                therapeutic_milestone: new_milestone,
                session_data_hash: data.session_data_hash,
                is_collaborative: data.is_collaborative
            };
            self.therapeutic_data.write(token_id, new_data);
            
            self.emit(MilestoneUpdated {
                token_id,
                old_milestone,
                new_milestone
            });
        }

        fn set_community_contribution(
            ref self: ContractState,
            token_id: u256,
            percentage: u32
        ) {
            // Check if token exists
            let _ = self.erc721.token_uri(token_id);
            assert(percentage <= 100, 'Invalid percentage');
            
            // Only token owner can set community contribution
            let token_owner = self.erc721.owner_of(token_id);
            assert(get_caller_address() == token_owner, 'Not token owner');
            
            self.community_contributions.write(token_id, percentage);
            
            self.emit(CommunityContributionSet {
                token_id,
                percentage
            });
        }

        fn get_community_contribution(self: @ContractState, token_id: u256) -> u32 {
            // Check if token exists
            let _ = self.erc721.token_uri(token_id);
            self.community_contributions.read(token_id)
        }

        fn get_total_supply(self: @ContractState) -> u256 {
            self.token_counter.read()
        }

        fn set_base_uri(ref self: ContractState, new_base_uri: ByteArray) {
            self.ownable.assert_only_owner();
            self.base_uri.write(new_base_uri.clone());
            self.erc721._set_base_uri(new_base_uri);
        }

        fn get_base_uri(self: @ContractState) -> ByteArray {
            self.base_uri.read()
        }

        fn get_user_tokens(self: @ContractState, user: ContractAddress) -> Array<u256> {
            let total_supply = self.token_counter.read();
            let mut user_tokens = ArrayTrait::new();
            let mut i: u256 = 1;
            
            while i <= total_supply {
                // Check if token exists and get owner
                let balance = self.erc721.balance_of(user);
                if balance > 0 {
                    // Simple check - in production you'd want a more efficient method
                    let current_owner = self.erc721.owner_of(i);
                    if current_owner == user {
                        user_tokens.append(i);
                    }
                }
                i += 1;
            };
            
            user_tokens
        }

        fn get_user_milestones(self: @ContractState, user: ContractAddress) -> Array<u32> {
            let user_tokens = self.get_user_tokens(user);
            let mut milestones = ArrayTrait::new();
            
            let mut i = 0;
            while i < user_tokens.len() {
                let token_id = *user_tokens.at(i);
                let data = self.therapeutic_data.read(token_id);
                milestones.append(data.therapeutic_milestone);
                i += 1;
            };
            
            milestones
        }
    }
}

#[starknet::interface]
trait IIturaNFT<TContractState> {
    fn mint_therapeutic_nft(
        ref self: TContractState,
        to: starknet::ContractAddress,
        therapeutic_milestone: u32,
        session_data_hash: felt252,
        is_collaborative: bool
    ) -> u256;
    
    fn get_therapeutic_data(self: @TContractState, token_id: u256) -> (u32, felt252, bool);
    
    fn update_milestone(ref self: TContractState, token_id: u256, new_milestone: u32);
    
    fn set_community_contribution(ref self: TContractState, token_id: u256, percentage: u32);
    
    fn get_community_contribution(self: @TContractState, token_id: u256) -> u32;
    
    fn get_total_supply(self: @TContractState) -> u256;
    
    fn set_base_uri(ref self: TContractState, new_base_uri: ByteArray);
    
    fn get_base_uri(self: @TContractState) -> ByteArray;
    
    fn get_user_tokens(self: @TContractState, user: starknet::ContractAddress) -> Array<u256>;
    
    fn get_user_milestones(self: @TContractState, user: starknet::ContractAddress) -> Array<u32>;
}