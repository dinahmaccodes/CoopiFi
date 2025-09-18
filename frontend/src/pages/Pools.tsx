import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Zap, TrendingUp, Shield, Coins } from "lucide-react";

const pools = [
  {
    name: "Wrapped USDC",
    symbol: "wUSDC",
    description: "Stable yield farming with wrapped USDC tokens",
    balance: "$1,200,000",
    apy: "8.5%",
    risk: "Low Risk",
    riskLevel: 1,
    utilization: 85,
    icon: "💵",
  },
  {
    name: "Wrapped ETH",
    symbol: "wETH",
    description: "Higher yield potential with Ethereum exposure",
    balance: "$850,000",
    apy: "12.3%",
    risk: "Medium Risk",
    riskLevel: 2,
    utilization: 73,
    icon: "🔷",
  },
  {
    name: "Wrapped Bitcoin",
    symbol: "wBTC",
    description:
      "Bitcoin-backed pool with higher yield potential and enhanced security",
    balance: "$400,000",
    apy: "14.2%",
    risk: "Low Risk",
    riskLevel: 1,
    utilization: 91,
    icon: "💰",
  },
];

const getRiskColor = (level: number) => {
  switch (level) {
    case 1:
      return "success";
    case 2:
      return "warning";
    case 3:
      return "destructive";
    default:
      return "secondary";
  }
};

export default function Pools() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold text-foreground">Liquidity Pools</h1>
        <p className="text-muted-foreground">
          Stake your tokens in liquidity pools to earn rewards and support the
          cooperative ecosystem.
        </p>
      </div>

      {/* Pool Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="bg-gradient-card border-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2">
              <Zap className="h-4 w-4 text-coopifi-primary" />
              <span className="text-sm text-muted-foreground">Total Pools</span>
            </div>
            <div className="text-2xl font-bold text-card-foreground mt-1">
              {pools.length}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2">
              <Coins className="h-4 w-4 text-coopifi-primary" />
              <span className="text-sm text-muted-foreground">Total Value</span>
            </div>
            <div className="text-2xl font-bold text-card-foreground mt-1">
              $2.45M
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-coopifi-primary" />
              <span className="text-sm text-muted-foreground">Avg APY</span>
            </div>
            <div className="text-2xl font-bold text-card-foreground mt-1">
              9.5%
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardContent className="p-4">
            <div className="flex items-center gap-2">
              <Shield className="h-4 w-4 text-coopifi-primary" />
              <span className="text-sm text-muted-foreground">Protected</span>
            </div>
            <div className="text-2xl font-bold text-card-foreground mt-1">
              100%
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Individual Pools */}
      <div className="space-y-6">
        {pools.map((pool, index) => (
          <Card
            key={index}
            className="bg-gradient-card border-border hover:border-coopifi-primary/50 transition-colors"
          >
            <CardHeader>
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="text-2xl">{pool.icon}</div>
                  <div>
                    <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
                      {pool.name}
                      <Badge
                        variant="outline"
                        className={`border-${getRiskColor(
                          pool.riskLevel
                        )} text-${getRiskColor(pool.riskLevel)}`}
                      >
                        {pool.risk}
                      </Badge>
                    </CardTitle>
                    <CardDescription className="text-muted-foreground">
                      {pool.description}
                    </CardDescription>
                  </div>
                </div>
                <Button className="bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground">
                  Stake in Pool
                </Button>
              </div>
            </CardHeader>

            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground">Pool Balance</p>
                  <p className="text-lg font-semibold text-card-foreground">
                    {pool.balance}
                  </p>
                </div>

                <div>
                  <p className="text-sm text-muted-foreground">Annual Yield</p>
                  <p className="text-lg font-semibold text-success">
                    {pool.apy}
                  </p>
                </div>

                <div>
                  <p className="text-sm text-muted-foreground">Token Symbol</p>
                  <p className="text-lg font-semibold text-card-foreground">
                    {pool.symbol}
                  </p>
                </div>

                <div>
                  <p className="text-sm text-muted-foreground">
                    Pool Utilization
                  </p>
                  <div className="flex items-center gap-2 mt-1">
                    <Progress value={pool.utilization} className="flex-1" />
                    <span className="text-sm font-medium text-card-foreground">
                      {pool.utilization}%
                    </span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Pool Statistics Summary */}
      <Card className="bg-gradient-card border-border">
        <CardHeader>
          <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
            <TrendingUp className="h-5 w-5 text-coopifi-primary" />
            Pool Statistics
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-center">
            <div>
              <div className="text-2xl font-bold text-card-foreground">
                $2.45M
              </div>
              <p className="text-sm text-muted-foreground">
                Total Value Locked
              </p>
            </div>
            <div>
              <div className="text-2xl font-bold text-card-foreground">
                9.5%
              </div>
              <p className="text-sm text-muted-foreground">Average APY</p>
            </div>
            <div>
              <div className="text-2xl font-bold text-card-foreground">3</div>
              <p className="text-sm text-muted-foreground">Active Pools</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
