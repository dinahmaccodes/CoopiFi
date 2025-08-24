import FAQSection from "@/components/landing-page/faq-section";
import FeaturesSection from "@/components/landing-page/features-section";
import Footer from "@/components/landing-page/footer";
import Header from "@/components/landing-page/header";
import HeroSection from "@/components/landing-page/hero-section";
import WaitlistSection from "@/components/landing-page/waitlist-section";


export default function LandingPage() {
  return (
    <div className="min-h-screen" style={{ backgroundColor: "#070021" }}>
      <Header />
      <main>
        <HeroSection />
        <FeaturesSection />
        <FAQSection />
        <WaitlistSection />
      </main>
      <Footer />
    </div>
  );
}
