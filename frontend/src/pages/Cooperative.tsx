import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Users, DollarSign, TrendingUp, Activity } from "lucide-react";

const cooperativeData = {
  name: "Green Energy Cooperative",
  description: "Renewable energy investment pool focused on solar and wind projects.",
  members: 156,
  yourStake: "$15,000",
  totalAssets: "$2,450,000",
  performance: "+12.5%",
  riskLevel: "Medium",
};

const liquidityPools = [
  {
    name: "USDC Pool",
    symbol: "wUSDC",
    balance: "$1,200,000",
    apy: "8.5%",
    risk: "Stable",
    riskColor: "success"
  },
  {
    name: "ETH Pool", 
    symbol: "wETH",
    balance: "$850,000",
    apy: "12.3%",
    risk: "Volatile",
    riskColor: "warning"
  },
  {
    name: "USDT Pool",
    symbol: "wUSDT", 
    balance: "$400,000",
    apy: "7.8%",
    risk: "Stable",
    riskColor: "success"
  }
];

export default function Cooperative() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold text-foreground">Your Cooperative</h1>
        <p className="text-muted-foreground">
          Overview of your cooperative membership and assets.
        </p>
      </div>

      {/* Cooperative Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="bg-gradient-card border-border">
          <CardHeader>
            <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
              <Users className="h-5 w-5 text-coopifi-primary" />
              Cooperative Details
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <h3 className="font-semibold text-card-foreground">{cooperativeData.name}</h3>
              <p className="text-sm text-muted-foreground">{cooperativeData.description}</p>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Total Members</span>
              <Badge variant="secondary" className="bg-coopifi-accent text-coopifi-secondary">
                {cooperativeData.members}
              </Badge>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Your Stake</span>
              <span className="font-semibold text-card-foreground">{cooperativeData.yourStake}</span>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardHeader>
            <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
              <DollarSign className="h-5 w-5 text-coopifi-primary" />
              Total Assets
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="text-3xl font-bold text-card-foreground">
              {cooperativeData.totalAssets}
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Performance</span>
              <div className="flex items-center gap-1 text-success">
                <TrendingUp className="h-4 w-4" />
                <span className="font-semibold">{cooperativeData.performance}</span>
              </div>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Risk Level</span>
              <Badge variant="outline" className="border-warning text-warning">
                {cooperativeData.riskLevel}
              </Badge>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Liquidity Pool Assets */}
      <div className="space-y-4">
        <div className="flex items-center gap-2">
          <Activity className="h-5 w-5 text-coopifi-primary" />
          <h2 className="text-2xl font-semibold text-foreground">Liquidity Pool Assets</h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {liquidityPools.map((pool, index) => (
            <Card key={index} className="bg-gradient-card border-border">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg text-card-foreground">{pool.name}</CardTitle>
                  <Badge 
                    variant="outline" 
                    className={`border-${pool.riskColor} text-${pool.riskColor}`}
                  >
                    {pool.risk}
                  </Badge>
                </div>
                <CardDescription className="text-muted-foreground">
                  {pool.symbol}
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-2xl font-bold text-card-foreground">
                  {pool.balance}
                </div>
                
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground">APY</span>
                  <span className="font-semibold text-success">{pool.apy}</span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Pool Statistics */}
      <Card className="bg-gradient-card border-border">
        <CardHeader>
          <CardTitle className="text-xl text-card-foreground">Pool Statistics</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-center">
            <div>
              <div className="text-2xl font-bold text-card-foreground">$2.45M</div>
              <p className="text-sm text-muted-foreground">Total Value Locked</p>
            </div>
            <div>
              <div className="text-2xl font-bold text-card-foreground">9.5%</div>
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