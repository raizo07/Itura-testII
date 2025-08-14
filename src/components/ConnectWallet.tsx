"use client"

import { useContext, useEffect, useState } from "react";
import { StarknetContext } from "@/contexts/Usercontext";
import { useAccount, useConnect, useDisconnect } from '@starknet-react/core'
import {ControllerConnector} from '@cartridge/connector'
import { Dialog, DialogPanel } from "@headlessui/react";
import Image from "next/image";


const ConnectWallet = () => {
  const { handleConnect } = useContext(StarknetContext);
  const { connectors } = useConnect();
  // const { disconnect } = useDisconnect()
  const { address } = useAccount()
  
  // Safely get the controller connector
  const controller = connectors.find(c => c instanceof ControllerConnector) as ControllerConnector | undefined;
  const [, setUsername] = useState<string>()
  const [isOpen, setIsOpen] = useState(false);
  console.log("Available connectors:", connectors)

  const open = () => setIsOpen(true);
  const close = () => setIsOpen(false);

  useEffect(() => {
    if (!address || !controller) return
    
    // Safely call username method with error handling
    try {
      controller.username()?.then((n) => setUsername(n)).catch((error) => {
        console.warn("Failed to get username:", error);
      });
    } catch (error) {
      console.warn("Controller username error:", error);
    }
  }, [address, controller])
 
 
    // Render connection UI
  const renderConnectionButton = () => {
    if (address) {
      return (
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-green-500 rounded-full"></div>
          <span className="text-sm">Connected</span>
        </div>
      );
    }

    return (
      <button
        onClick={open}
        className="bg-gradient-to-r from-orange to-lightOrange rounded-xl text-white p-3 px-6"
      >
        Connect Wallet
      </button>
    );
  };

  return ( 
    <>
      {renderConnectionButton()}
     <Dialog open={isOpen} onClose={close}>
     <div className="absolute top-36 right-20 flex lg:w-[25%] md:w-[35%] w-[90%] z-50">
       <DialogPanel className="bg-darkBg p-6 shadow-xl rounded-[21px] border border-white/20 w-full">
         <div className="flex flex-col items-center mb-6">
           <p className="text-xs font-medium text-white mb-2">Connect to</p>
            <Image
            src="https://res.cloudinary.com/dqw6qvymf/image/upload/v1752604683/logo_jpexvw.svg"
            alt="Itura's logo"
            width={60}
            height={60}
        />
         </div>
         {connectors.map((connector) => (
           <div
             key={connector.id}
             className="bg-white/10 hover:bg-white/20 border border-white/10 rounded-[21px] cursor-pointer px-4 py-2 text-white flex items-center w-full mb-4 transition capitalize"
             onClick={() => {
               handleConnect(connector)
               close();
             }} 
           >
             <div className="w-[40px] h-[40px] rounded-full bg-white/5 border border-white/10 flex justify-center items-center p-2 mr-4">
               <img
                 src={typeof connector.icon === 'string' ? connector.icon : connector.icon.dark}
                 alt={`${connector.name} logo`}
                 className="w-[30px] h-[30px]"
               />
             </div>
             <button>{connector.name}</button>
           </div>
         ))}
       </DialogPanel>
     </div>
   </Dialog>
   </>
  );
};

export default ConnectWallet;