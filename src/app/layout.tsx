import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "sonner";
import dynamic from "next/dynamic";

const StarknetContextProvider = dynamic(
  () =>
    import("@/contexts/Usercontext").then((mod) => mod.StarknetContextProvider),
  { ssr: false }
);
const StarknetProvider = dynamic(
  () =>
    import("@/components/StarknetProvider").then((mod) => mod.StarknetProvider),
  { ssr: false }
);
const WalletConnectionWrapper = dynamic(
  () =>
    import("@/components/WalletConnectionWrapper").then((mod) => mod.WalletConnectionWrapper),
  { ssr: false }
);

export const metadata: Metadata = {
  title: "Itura",
  description: "Your Web3 Art Studio",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="font-inter max-w-[1560px] mx-auto">
        <WalletConnectionWrapper>
          <StarknetProvider>
            <StarknetContextProvider>
              {children}
              <Toaster richColors={true} position="top-right" />
            </StarknetContextProvider>
          </StarknetProvider>
        </WalletConnectionWrapper>
      </body>
    </html>
  );
}
