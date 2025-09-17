import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { TrendingUp, Clock, Shield, Calculator } from "lucide-react";

const stakingOptions = [
  {
    name: "wUSDC",
    apy: "8.5%",
    risk: "Low Risk",
    riskColor: "success",
    minStake: "100"
  },
  {
    name: "wETH", 
    apy: "12.3%",
    risk: "Medium Risk",
    riskColor: "warning",
    minStake: "0.1"
  },
  {
    name: "wBTC",
    apy: "14.2%", 
    risk: "Medium Risk",
    riskColor: "warning",
    minStake: "0.001"
  }
];

const stakingBenefits = [
  "Daily Rewards - Earn rewards every day",
  "Compound Growth - Automatically reinvest earnings",
  "Insurance Protected - Your stake is protected by cooperative insurance"
];

export default function Stake() {
  const [selectedPool, setSelectedPool] = useState("wUSDC");
  const [stakeAmount, setStakeAmount] = useState("");
  const [estimatedReturns, setEstimatedReturns] = useState("$0.00");

  const calculateReturns = (amount: string, apy: string) => {
    if (!amount || isNaN(Number(amount))) return "$0.00";
    const principal = Number(amount);
    const rate = Number(apy.replace('%', '')) / 100;
    const annual = principal * rate;
    return `$${annual.toFixed(2)}`;
  };

  const handleAmountChange = (value: string) => {
    setStakeAmount(value);
    const selected = stakingOptions.find(opt => opt.name === selectedPool);
    if (selected) {
      setEstimatedReturns(calculateReturns(value, selected.apy));
    }
  };

  const selectedOption = stakingOptions.find(opt => opt.name === selectedPool);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold text-foreground">Stake Tokens</h1>
        <p className="text-muted-foreground">
          Stake your tokens to earn rewards and participate in cooperative governance.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Staking Form */}
        <div className="space-y-6">
          <Card className="bg-gradient-card border-border">
            <CardHeader>
              <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-coopifi-primary" />
                Stake Tokens
              </CardTitle>
              <CardDescription className="text-muted-foreground">
                Select a pool and amount to stake
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Pool Selection */}
              <div className="space-y-3">
                <Label className="text-card-foreground">Select Pool</Label>
                <div className="grid gap-3">
                  {stakingOptions.map((option) => (
                    <div
                      key={option.name}
                      className={`p-4 rounded-lg border cursor-pointer transition-colors ${
                        selectedPool === option.name
                          ? 'border-coopifi-primary bg-coopifi-primary/10'
                          : 'border-border bg-card/50 hover:border-coopifi-primary/50'
                      }`}
                      onClick={() => setSelectedPool(option.name)}
                    >
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-medium text-card-foreground">{option.name}</span>
                            <Badge 
                              variant="outline" 
                              className={`border-${option.riskColor} text-${option.riskColor}`}
                            >
                              {option.risk}
                            </Badge>
                          </div>
                          <p className="text-sm text-muted-foreground">Min stake: {option.minStake} {option.name}</p>
                        </div>
                        <div className="text-right">
                          <div className="font-semibold text-success">{option.apy}</div>
                          <p className="text-xs text-muted-foreground">APY</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Amount Input */}
              <div className="space-y-2">
                <Label htmlFor="amount" className="text-card-foreground">Amount to Stake</Label>
                <div className="relative">
                  <Input
                    id="amount"
                    type="number"
                    placeholder="0.00"
                    value={stakeAmount}
                    onChange={(e) => handleAmountChange(e.target.value)}
                    className="pr-16 bg-background border-border text-foreground"
                  />
                  <div className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                    {selectedPool}
                  </div>
                </div>
                {selectedOption && (
                  <p className="text-xs text-muted-foreground">
                    Minimum stake: {selectedOption.minStake} {selectedPool}
                  </p>
                )}
              </div>

              {/* Estimated Returns */}
              <Card className="bg-card/30 border-border">
                <CardContent className="p-4">
                  <div className="flex items-center gap-2 mb-3">
                    <Calculator className="h-4 w-4 text-coopifi-primary" />
                    <span className="font-medium text-card-foreground">Estimated Annual Returns</span>
                  </div>
                  <div className="text-2xl font-bold text-success">{estimatedReturns}</div>
                  <p className="text-xs text-muted-foreground mt-1">
                    Based on current APY of {selectedOption?.apy || "0%"}
                  </p>
                </CardContent>
              </Card>

              <Button 
                className="w-full bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground"
                disabled={!stakeAmount || Number(stakeAmount) < Number(selectedOption?.minStake || 0)}
              >
                Stake Tokens
              </Button>
            </CardContent>
          </Card>
        </div>

        {/* Current Stakes & Benefits */}
        <div className="space-y-6">
          {/* Current Stakes */}
          <Card className="bg-gradient-card border-border">
            <CardHeader>
              <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
                <Shield className="h-5 w-5 text-coopifi-primary" />
                Your Current Stakes
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-3 bg-card/30 rounded-lg">
                  <div>
                    <p className="font-medium text-card-foreground">wUSDC Pool</p>
                    <p className="text-sm text-muted-foreground">Active</p>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-card-foreground">$5,000</p>
                    <Badge variant="secondary" className="bg-coopifi-accent text-coopifi-secondary">
                      Active
                    </Badge>
                  </div>
                </div>
              </div>

              <Separator className="bg-border" />

              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Total Staked</span>
                  <span className="font-semibold text-card-foreground">$5,000</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Active Stakes</span>
                  <span className="font-semibold text-card-foreground">1</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Staking Benefits */}
          <Card className="bg-gradient-card border-border">
            <CardHeader>
              <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
                <Clock className="h-5 w-5 text-coopifi-primary" />
                Staking Benefits
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {stakingBenefits.map((benefit, index) => {
                const [title, description] = benefit.split(" - ");
                return (
                  <div key={index} className="flex items-start gap-3">
                    <div className="w-2 h-2 bg-coopifi-primary rounded-full mt-2 flex-shrink-0" />
                    <div>
                      <p className="font-medium text-card-foreground">{title}</p>
                      <p className="text-sm text-muted-foreground">{description}</p>
                    </div>
                  </div>
                );
              })}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}