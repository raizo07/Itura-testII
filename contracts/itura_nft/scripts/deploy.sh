#!/bin/bash

# ITURA NFT Contract Deployment Script
# This script deploys the ITURA therapeutic NFT contract to Starknet

echo "🚀 ITURA NFT Contract Deployment"
echo "================================"

# Set deployment parameters
NETWORK="sepolia"  # Change to "mainnet" for production
CONTRACT_NAME="IturaNFT"
NAME="ITURA Therapeutic NFT"
SYMBOL="ITURA"
BASE_URI="https://api.itura.org/metadata/"

# Owner address - replace with actual deployment address
OWNER_ADDRESS="0x123...abc"  # TODO: Replace with actual owner address

echo "📋 Deployment Configuration:"
echo "Network: $NETWORK"
echo "Contract: $CONTRACT_NAME"
echo "Name: $NAME"
echo "Symbol: $SYMBOL"
echo "Base URI: $BASE_URI"
echo "Owner: $OWNER_ADDRESS"
echo ""

# Build the contract
echo "🔧 Building contract..."
scarb build

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Declare the contract
echo "📝 Declaring contract to $NETWORK..."
DECLARE_OUTPUT=$(sncast --url "https://starknet-$NETWORK.g.alchemy.com/starknet/version/rpc/v0_8/" declare --contract-name $CONTRACT_NAME 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Declaration failed!"
    echo "$DECLARE_OUTPUT"
    exit 1
fi

# Extract class hash from declare output
CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -o "0x[a-fA-F0-9]\{64\}" | head -1)

if [ -z "$CLASS_HASH" ]; then
    echo "❌ Could not extract class hash!"
    echo "$DECLARE_OUTPUT"
    exit 1
fi

echo "✅ Contract declared with class hash: $CLASS_HASH"
echo ""

# Deploy the contract
echo "🚀 Deploying contract..."
DEPLOY_OUTPUT=$(sncast --url "https://starknet-$NETWORK.g.alchemy.com/starknet/version/rpc/v0_8/" deploy --class-hash $CLASS_HASH --constructor-calldata "$NAME" "$SYMBOL" "$BASE_URI" "$OWNER_ADDRESS" 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi

# Extract contract address from deploy output  
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -o "0x[a-fA-F0-9]\{64\}" | head -1)

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "❌ Could not extract contract address!"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi

echo "✅ Contract deployed successfully!"
echo ""
echo "📄 Deployment Summary:"
echo "======================="
echo "Network: $NETWORK"
echo "Class Hash: $CLASS_HASH"  
echo "Contract Address: $CONTRACT_ADDRESS"
echo "Explorer: https://$NETWORK.voyager.online/contract/$CONTRACT_ADDRESS"
echo ""
echo "🎉 ITURA NFT contract is ready for use!"
echo ""
echo "📝 Next steps:"
echo "1. Update your frontend ABI and contract address"
echo "2. Verify the contract on Voyager"
echo "3. Test minting functionality"
echo "4. Set up proper access controls"
