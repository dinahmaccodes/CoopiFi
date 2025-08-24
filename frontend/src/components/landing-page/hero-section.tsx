// import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";

export default function HeroSection() {
  return (
    <section className="px-6 lg:px-[150px] py-20 lg:py-32">
      <div className="max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          <div>
            <p className="text-blue-400 mb-4">Powered by Starknet</p>
            <h1 className="text-4xl lg:text-6xl font-bold text-white mb-6 leading-tight">
              Lend and Borrow Crypto Effortlessly on Starknet
            </h1>
            <p className="text-gray-400 text-lg mb-8 leading-relaxed">
              Experience DeFi like never before — lend or borrow with zero gas
              fees, and unlock the power of Starknet&apos;s seamless, scalable
              blockchain
            </p>
            {/* <Button
              size="lg"
              className="bg-transparent border-2 border-white text-[#C9B3F5] hover:bg-white hover:text-[#070021] transition-colors px-8 py-3"
            >
              Open App
            </Button> */}
            <Link
              to="/dashboard"
              className="relative px-6 py-3 rounded-full bg-[#070021] text-white hover:text-[#070021] transition-all duration-300 font-medium overflow-hidden group"
              style={{
                background:
                  "linear-gradient(#070021, #070021) padding-box, linear-gradient(to right, #88AAF1, #A0D2F3, #B8FAF6) border-box",
                border: "2px solid transparent",
              }}
            >
              <span className="relative z-10">Open App</span>
              <div className="absolute inset-0 bg-gradient-to-r from-[#88AAF1] via-[#A0D2F3] to-[#B8FAF6] opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-full"></div>
            </Link>
          </div>

          <div className="relative flex justify-center items-center">
            <div className="relative">
              <img
                src="/stacked-coins.svg"
                alt="Stacked coins illustration"
                width={500}
                height={500}
                className="w-full h-auto max-w-md animate-float"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Bottom border line */}
      <div className="max-w-7xl mx-auto mt-[150px]">
        <div className="h-px bg-blue-500"></div>
      </div>
    </section>
  );
}
