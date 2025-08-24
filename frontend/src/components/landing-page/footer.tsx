import { Twitter, Github } from "lucide-react";

export default function Footer() {
  return (
    <footer className="px-[150px] pb-[80px]">
      <div className="max-w-7xl mx-auto bg-[#0C0035] px-6 lg:px-[150px] py-12 border-t border-blue-500">
        <div className="grid lg:grid-cols-2 gap-8 items-start">
          {/* Left side - Logo and description */}
          <div className="space-y-6">
            <div className="flex items-center gap-3">
              <img src="/coopifi-logo.svg" alt="coopifi-logo" />
            </div>
            <p className="text-gray-400 text-sm leading-relaxed max-w-md">
              CoopiFi redefines crypto lending and borrowing with a single
              click. Sign in with ease, supply liquidity, borrow against
              collateral, and enjoy gasless transactions—powered by
              Starknet&apos;s scalable, user-friendly blockchain.
            </p>
          </div>

          {/* Right side - Links and social */}
          <div className="flex justify-between items-start">
            <div className="flex gap-16">
              <div>
                <h3 className="text-white font-semibold mb-4">Resources</h3>
                <ul className="space-y-2">
                  <li>
                    <a
                      href="#faq"
                      className="text-gray-400 hover:text-white transition-colors text-sm"
                    >
                      FAQ
                    </a>
                  </li>
                </ul>
              </div>
              <div>
                <h3 className="text-white font-semibold mb-4">Developers</h3>
                <ul className="space-y-2">
                  <li>
                    <a
                      href="#"
                      className="text-gray-400 hover:text-white transition-colors text-sm"
                    >
                      Documentation
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            {/* Social icons */}
            <div className="flex gap-4">
              <a
                href="#"
                title="Follow us on Twitter"
                className="w-8 h-8 rounded-full border border-gray-600 flex items-center justify-center hover:border-blue-400 hover:text-blue-400 text-white transition-colors"
              >
                <Twitter className="w-4 h-4" />
              </a>
              <a
                href="#"
                title="View our GitHub"
                className="w-8 h-8 rounded-full border border-gray-600 flex items-center text-white justify-center hover:border-blue-400 hover:text-blue-400 transition-colors"
              >
                <Github className="w-4 h-4" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
