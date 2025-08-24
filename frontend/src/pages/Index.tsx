import { Button } from "@/components/ui/button";
import { Building2, ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";
import { useEffect } from "react";

const Index = () => {
  useEffect(() => {
    // Force dark mode
    document.documentElement.classList.add('dark');
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="text-center space-y-8 max-w-2xl mx-auto px-6">
        <div className="space-y-4">
          <div className="flex items-center justify-center">
            <Building2 className="h-16 w-16 text-coopifi-primary" />
          </div>
          <h1 className="text-5xl font-bold text-foreground">
            Welcome to <span className="text-coopifi-primary">CoopiFi</span>
          </h1>
          <p className="text-xl text-muted-foreground">
            Decentralized cooperative finance platform for sustainable investments
          </p>
        </div>
        
        <div className="space-y-4">
          <p className="text-foreground">
            Join cooperatives, stake tokens, and earn rewards while supporting sustainable initiatives.
          </p>
          
          <Link to="/dashboard">
            <Button 
              size="lg" 
              className="bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground px-8 py-3 text-lg"
            >
              Open App
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Index;
