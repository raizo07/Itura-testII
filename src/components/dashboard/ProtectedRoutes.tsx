"use client";

import { useContext, useEffect } from "react";
import { useRouter } from "next/navigation";
import { StarknetContext } from "@/contexts/Usercontext";
import { toast } from "sonner";
import { usePathname } from "next/navigation";

interface Props {
  children: React.ReactNode;
}

const ProtectedRoute = ({ children }: Props) => {
  const { address, status } = useContext(StarknetContext);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!address || status !== "connected") {
      toast.error("Connect your wallet to access this page.", { position: "top-center" });
      router.push(`/dashboard/auth/not-authenticated`);
    } else {
      return;
    }
  }, [address, status, router, pathname]);

  return <>{children}</>;
};

export default ProtectedRoute;