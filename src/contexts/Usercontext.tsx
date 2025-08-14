"use client";

import { createContext, useState, useEffect, ReactNode } from "react";
import abi from "../Abis/abi.json";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";
import { ControllerConnector } from "@cartridge/connector";
import { Connector } from "@starknet-react/core";

// Define types to avoid direct imports that cause SSR issues
type SessionAccountInterface = any;

// Dynamically import browser-only modules
// let argentWebWallet: any = null;
// let deployAndExecuteWithPaymaster: any = null;

interface StarknetContextType {
  isLoading: boolean;
  setIsLoading: (isLoading: boolean) => void;
  account: SessionAccountInterface | undefined;
  setAccount: (account: SessionAccountInterface | undefined) => void;
  contractAddr: `0x${string}`;
  abi: any;
  token_addr: `0x${string}`;
  address: String | undefined;
  status: "disconnected" | "connected" | "connecting" | "reconnecting";
  handleClearSession: () => Promise<void>;
  // handleConnect: () => Promise<void>;
  setAddress: (address: String | undefined) => void;
  username: string | undefined;
  handleConnect: (connector: Connector) => Promise<void>;
}

export const StarknetContext = createContext<StarknetContextType>(
  {} as StarknetContextType
);

interface StarknetProviderProps {
  children: ReactNode;
}

export const StarknetContextProvider = ({
  children,
}: StarknetProviderProps) => {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  
  const router = useRouter();
  const {
    address: cartridgeAddress,
    account: cartridgeAccount,
    status,
  } = useAccount();
  const [isLoading, setIsLoading] = useState(false);
  const [account, setAccount] = useState<SessionAccountInterface | undefined>(
    undefined
  );
  const [address, setAddress] = useState<String | undefined>(undefined);
  
  // Safely get the controller connector
  const controller = connectors.find(c => c instanceof ControllerConnector) as ControllerConnector | undefined;
  const [username, setUsername] = useState<string>();

  // Handle username fetching with error handling
  useEffect(() => {
    if (!address || !controller) return;
    
    try {
      controller.username()?.then((n) => setUsername(n)).catch((error) => {
        console.warn("Failed to get username:", error);
      });
    } catch (error) {
      console.warn("Controller username error:", error);
    }
  }, [address, controller]);
  // const [isClient, setIsClient] = useState(false);

  // Contract Addresses
  const token_addr =
    (process.env.NEXT_PUBLIC_TOKEN_ADDRESS as `0x${string}`) || "0x0";
  const contractAddr =
    (process.env.NEXT_PUBLIC_CONTRACT_ADDRESS as `0x${string}`) || "0x0";

  // set the cartrige controller

//   useEffect(() => {
//     setAddress(cartridgeAddress);
//     setAccount(cartridgeAccount);
//   }, [status]);

  const handleClearSession = async () => {
    try {
      disconnect();
      setAccount(undefined);
      setAddress(undefined);
      router.push("/");
      toast.success("Wallet Disconnected Successfully");
    } catch (err) {
      toast.error(`Error disconnecting:${err}`);
    }
  };

const handleConnect = async (connector: Connector) => {
    try {
      connect({ connector });
    } catch (err) {
      toast.error(`Connection failed: ${err}`);
    }
  };
 
  useEffect(() => {
    if (address && account) {
      setAddress(address);
      setAccount(account);
    }
  }, [address, account]);

  return (
    <StarknetContext.Provider
      value={{
        isLoading,
        setIsLoading,
        account,
        setAccount,
        contractAddr,
        abi,
        token_addr,
        address,
        status,
        handleClearSession,
        setAddress,
        username,
        handleConnect,
      }}
    >
      {children}
    </StarknetContext.Provider>
  );
};
