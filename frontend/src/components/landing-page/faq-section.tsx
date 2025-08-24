import { useState } from "react";
import { ChevronDown, Plus } from "lucide-react";

const faqs = [
  {
    question: "What is CoopiFi?",
    answer:
      "CoopiFi is a decentralized platform enabling community-based lending pools (cooperatives) where users can join or create lending cooperatives, stake stablecoins to fund pools, and request loans with crypto collateral.",
    isOpen: true,
  },
  {
    question: "How do lending cooperatives work?",
    answer:
      "Users can create or join cooperatives where they stake stablecoins to fund lending pools. Members can then request loans against crypto collateral, with the community voting on approvals and governance parameters.",
    isOpen: false,
  },
  {
    question: "What are the benefits of using CoopiFi?",
    answer:
      "CoopiFi offers zero gas fees, instant transactions, transparent on-chain governance, NFT-based membership, and community-driven lending decisions—all powered by Starknet's advanced technology.",
    isOpen: false,
  },
  {
    question: "How is membership managed?",
    answer:
      "When you join a cooperative, you receive an NFT membership token that represents your voting rights and access to the pool. This NFT can be transferred or sold (feature coming soon).",
    isOpen: false,
  },
];

export default function FAQSection() {
  const [openItems, setOpenItems] = useState<number[]>([0]);

  const toggleItem = (index: number) => {
    setOpenItems((prev) =>
      prev.includes(index) ? prev.filter((i) => i !== index) : [...prev, index]
    );
  };

  return (
    <section id="faq" className="px-6 lg:px-[150px] py-20">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl lg:text-4xl font-bold text-white mb-2">
            FAQ
          </h2>
          <div className="w-16 h-px bg-blue-500 mx-auto"></div>
        </div>

        <div className="space-y-6">
          {faqs.map((faq, index) => (
            <div key={index} className="border-b border-gray-700 pb-6">
              <button
                onClick={() => toggleItem(index)}
                className="flex items-center justify-between w-full text-left"
              >
                <h3 className="text-lg font-semibold text-white pr-4">
                  {faq.question}
                </h3>
                {openItems.includes(index) ? (
                  <ChevronDown className="w-5 h-5 text-white transform rotate-180 transition-transform" />
                ) : (
                  <Plus className="w-5 h-5 text-white" />
                )}
              </button>

              {openItems.includes(index) && (
                <div className="mt-4">
                  <p className="text-gray-400 leading-relaxed">{faq.answer}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
