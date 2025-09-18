import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  DollarSign,
  TrendingUp,
  Clock,
  Wallet,
  AlertCircle,
  ExternalLink,
} from "lucide-react";

const earningsData = {
  totalEarned: "$1,234.56",
  monthlyEarnings: "$456.78",
  activeStakes: 3,
};

const recentActivity = [
  {
    action: "wUSDC Rewards Claimed",
    amount: "+$23.45",
    date: "2 hours ago",
    type: "reward",
  },
  {
    action: "wETH Rewards Claimed",
    amount: "+$15.23",
    date: "1 day ago",
    type: "reward",
  },
  {
    action: "wBTC Rewards Claimed",
    amount: "+$12.45",
    date: "2 days ago",
    type: "reward",
  },
  {
    action: "Stake Added to wUSDC Pool",
    amount: "-$1,000.00",
    date: "1 week ago",
    type: "stake",
  },
];

export default function Earnings() {
  const [isWalletConnected, setIsWalletConnected] = useState(false);

  const ConnectWalletDialog = () => (
    <Dialog>
      <DialogTrigger asChild>
        <Button className="bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground">
          <Wallet className="h-4 w-4 mr-2" />
          Connect Wallet
        </Button>
      </DialogTrigger>
      <DialogContent className="bg-card border-border">
        <DialogHeader>
          <DialogTitle className="text-card-foreground">
            Connect Your Wallet
          </DialogTitle>
          <DialogDescription className="text-muted-foreground">
            Connect your wallet to view detailed earnings and transaction
            history.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          <Button
            className="w-full bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground"
            onClick={() => setIsWalletConnected(true)}
          >
            <Wallet className="h-4 w-4 mr-2" />
            Connect Wallet
          </Button>
          <p className="text-xs text-center text-muted-foreground">
            By connecting your wallet, you agree to our terms and conditions.
          </p>
        </div>
      </DialogContent>
    </Dialog>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold text-foreground">Your Earnings</h1>
        <p className="text-muted-foreground">
          Track your staking rewards and cooperative earnings.
        </p>
      </div>

      {/* Wallet Connection Alert */}
      {!isWalletConnected && (
        <Alert className="border-warning/50 bg-warning/10">
          <AlertCircle className="h-4 w-4 text-warning" />
          <AlertDescription className="text-card-foreground">
            <div className="flex items-center justify-between">
              <span>Connect your wallet to view detailed earnings</span>
              <ConnectWalletDialog />
            </div>
          </AlertDescription>
        </Alert>
      )}

      {/* Earnings Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">
              Total Earned
            </CardTitle>
            <DollarSign className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">
              {earningsData.totalEarned}
            </div>
            <p className="text-xs text-muted-foreground">
              All-time earnings from staking
            </p>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">
              Monthly Earnings
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">
              {earningsData.monthlyEarnings}
            </div>
            <p className="text-xs text-muted-foreground">
              Current month earnings
            </p>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">
              Active Stakes
            </CardTitle>
            <Clock className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">
              {earningsData.activeStakes}
            </div>
            <p className="text-xs text-muted-foreground">
              Currently earning rewards
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card className="bg-gradient-card border-border">
        <CardHeader>
          <CardTitle className="text-xl text-card-foreground flex items-center gap-2">
            <Clock className="h-5 w-5 text-coopifi-primary" />
            Recent Activity
          </CardTitle>
          <CardDescription className="text-muted-foreground">
            Your latest staking transactions and rewards
          </CardDescription>
        </CardHeader>
        <CardContent>
          {!isWalletConnected ? (
            <div className="text-center py-8 space-y-4">
              <p className="text-muted-foreground">
                Connect your wallet to view detailed activity
              </p>
              <ConnectWalletDialog />
            </div>
          ) : (
            <div className="space-y-4">
              {recentActivity.map((activity, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-4 bg-card/30 rounded-lg"
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-2 h-2 rounded-full ${
                        activity.type === "reward"
                          ? "bg-success"
                          : "bg-coopifi-primary"
                      }`}
                    />
                    <div>
                      <p className="font-medium text-card-foreground">
                        {activity.action}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {activity.date}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p
                      className={`font-semibold ${
                        activity.amount.startsWith("+")
                          ? "text-success"
                          : "text-card-foreground"
                      }`}
                    >
                      {activity.amount}
                    </p>
                    <Badge
                      variant="outline"
                      className={
                        activity.type === "reward"
                          ? "border-success text-success"
                          : "border-coopifi-primary text-coopifi-primary"
                      }
                    >
                      {activity.type}
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Earnings Breakdown */}
      {isWalletConnected && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card className="bg-gradient-card border-border">
            <CardHeader>
              <CardTitle className="text-xl text-card-foreground">
                Earnings by Pool
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {[
                { pool: "wUSDC Pool", earned: "$456.23", percentage: "37%" },
                { pool: "wETH Pool", earned: "$523.18", percentage: "42%" },
                { pool: "wBTC Pool", earned: "$367.89", percentage: "30%" },
              ].map((item, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-card-foreground">
                      {item.pool}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {item.percentage} of total
                    </p>
                  </div>
                  <p className="font-semibold text-success">{item.earned}</p>
                </div>
              ))}
            </CardContent>
          </Card>

          <Card className="bg-gradient-card border-border">
            <CardHeader>
              <CardTitle className="text-xl text-card-foreground">
                Quick Actions
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <Button
                variant="outline"
                className="w-full justify-between border-border text-card-foreground hover:bg-accent"
              >
                Claim All Rewards
                <ExternalLink className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="w-full justify-between border-border text-card-foreground hover:bg-accent"
              >
                Compound Earnings
                <ExternalLink className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                className="w-full justify-between border-border text-card-foreground hover:bg-accent"
              >
                Export Statement
                <ExternalLink className="h-4 w-4" />
              </Button>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
