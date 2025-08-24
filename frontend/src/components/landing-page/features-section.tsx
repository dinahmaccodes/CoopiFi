import { ArrowRight } from "lucide-react";

export default function FeaturesSection() {
  return (
    <section id="features" className="px-6 lg:px-[150px] py-20">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl lg:text-4xl font-bold text-white pb-3 border-b-[1px] border-[#B8FAF6] w-fit mx-auto">
            With CoopiFi you can
          </h2>
        </div>

        <div className="space-y-[60px]">
          {/* Supply liquidity and earn interest - Top Section */}
          <div className="grid grid-cols-2 gap-x-[60px] items-stretch">
            <div className="flex gap-[31px] justify-center items-center bg-[#06052D] py-[55px] rounded-[8px]">
              <img src="/usd-coin-gradient-logo.png" alt="usdc" />
              <img src="/usdt-coin-gradient-logo.png" alt="usdc" />
            </div>
            <div className="py-9">
              <h3 className="text-2xl font-medium text-white pb-6 border-b-[2px] border-b-[#05124B] mb-6">
                Supply liquidity and earn interest
              </h3>
              ￼
              <p className="text-[#737DA7] font-normal mb-6 text-lg">
                Power the future of DeFi on Starknet—supply liquidity, earn
                attractive interest, and enjoy gasless, seamless transactions
                with just a click.
              </p>
              <button className="flex items-center gap-2 text-white border-b border-white pb-1 hover:text-blue-400 hover:border-blue-400 transition-colors">
                Learn More <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Borrow Against Collateral - Middle Section with grid layout */}
          <div className="grid grid-cols-2 gap-x-[60px] items-stretch">
            {/* <div className > */}
            <div className="space-y-[60px]">
              {/* <div className="py-9"> */}
              <h3 className="text-2xl font-medium text-white pb-6 border-b-[2px] border-b-[#05124B] mb-6">
                Borrow Against Collateral
              </h3>
              <p className="text-[#737DA7] font-normal mb-6 text-lg">
                Unlock instant crypto loans on Starknet—borrow against your
                collateral with zero gas fees and a seamless, wallet-free
                experience.
              </p>

              {/* <button className="flex items-center gap-[10px] text-[#E2E2E2] border-b border-white pb-3 hover:text-blue-400 hover:border-blue-400 transition-colors"> */}
              <button className="flex items-center gap-2 text-white border-b border-white pb-1 hover:text-blue-400 hover:border-blue-400 transition-colors">
                Learn More <ArrowRight className="w-4 h-4" />
              </button>
            </div>
            <div className="flex gap-[31px] justify-center items-center bg-[#06052D] py-[55px] rounded-[8px]">
              <img src="/borrow-gradient-logo.png" alt="borrow" />
            </div>
            <div className="flex justify-center"></div>
          </div>

          {/* Exit or Repay - Bottom Section */}
          {/* <div className="flex items-start gap-8"> */}
          <div className="grid grid-cols-2 gap-x-[60px] items-stretch">
            <div className="flex gap-[31px] justify-center items-center bg-[#06052D] py-[55px] rounded-[8px]">
              <img src="/coins-gradient-logo.png" alt="coins-gradient" />
            </div>
            <div className="flex-1">
              {/* <h3 className="text-xl font-semibold text-white mb-4"> */}
              <h3 className="text-2xl font-medium text-white pb-6 border-b-[2px] border-b-[#05124B] mb-6">
                Exit or Repay
              </h3>
              {/* <p className="text-gray-400 mb-6 leading-relaxed"> */}
              <p className="text-[#737DA7] font-normal mb-6 text-lg">
                Effortlessly manage your CoopiFi journey on Starknet—repay loans
                or withdraw your assets with zero gas fees and a seamless,
                one-click experience.
              </p>
              <button className="flex items-center gap-2 text-white border-b border-white pb-1 hover:text-blue-400 hover:border-blue-400 transition-colors">
                Learn More <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
