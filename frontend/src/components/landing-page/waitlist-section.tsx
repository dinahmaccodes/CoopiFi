import type React from "react";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function WaitlistSection() {
  const [email, setEmail] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle waitlist signup
    console.log("Waitlist signup:", email);
    setEmail("");
  };

  return (
    <section id="waitlist" className="px-6 lg:px-[150px] py-20 pb-[80px]">
      <div className="max-w-7xl mx-auto">
        <div className="relative border border-blue-500 rounded-lg p-8 lg:p-12 overflow-hidden">
          {/* Striped pattern background */}
          <div className="absolute inset-0 opacity-5">
            <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <pattern
                  id="stripes"
                  patternUnits="userSpaceOnUse"
                  width="40"
                  height="40"
                  patternTransform="rotate(45)"
                >
                  <rect width="20" height="40" fill="url(#stripeGradient)" />
                </pattern>
                <linearGradient
                  id="stripeGradient"
                  x1="0%"
                  y1="0%"
                  x2="100%"
                  y2="100%"
                >
                  <stop offset="0%" stopColor="#3B82F6" />
                  <stop offset="50%" stopColor="#8B5CF6" />
                  <stop offset="100%" stopColor="#06B6D4" />
                </linearGradient>
              </defs>
              <rect width="100%" height="100%" fill="url(#stripes)" />
            </svg>
          </div>

          {/* Abstract geometric patterns */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-4 right-4 w-32 h-32 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full blur-xl"></div>
            <div className="absolute bottom-4 left-4 w-24 h-24 bg-gradient-to-tr from-cyan-500 to-blue-500 rounded-full blur-lg"></div>
            <div className="absolute top-1/2 left-1/3 w-16 h-16 border-2 border-blue-400 rotate-45 opacity-30"></div>
            <div className="absolute bottom-1/3 right-1/4 w-20 h-20 border border-purple-400 rounded-full opacity-20"></div>
          </div>

          <div className="relative z-10 grid lg:grid-cols-2 gap-8 items-center">
            <div>
              <h2 className="text-2xl lg:text-3xl font-bold text-white mb-4">
                Join the waitlist
              </h2>
              <p className="text-gray-400">
                Be the first to experience CoopiFi&apos;s effortless DeFi and
                community-driven lending.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="flex gap-4">
              <Input
                type="email"
                placeholder="Enter email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="flex-1 bg-transparent border-gray-600 text-white placeholder:text-gray-500 focus:border-blue-400"
                required
              />
              <Button
                type="submit"
                className="bg-transparent border-2 border-white text-white hover:bg-white hover:text-[#070021] transition-colors px-8"
              >
                Join
              </Button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}
