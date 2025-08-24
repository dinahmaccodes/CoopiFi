import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Building2, Users, TrendingUp } from "lucide-react";

const cooperatives = [
  {
    id: 1,
    name: "Green Energy Cooperative",
    description: "Renewable energy investment pool focused on solar and wind projects.",
    members: 156,
    totalAssets: "$2,450,000",
    type: "Energy"
  },
  {
    id: 2,
    name: "Urban Agriculture Co-op",
    description: "Supporting local farmers and sustainable agriculture initiatives.",
    members: 89,
    totalAssets: "$1,200,000",
    type: "Agriculture"
  },
  {
    id: 3,
    name: "Tech Innovation Collective",
    description: "Collaborative funding for emerging technology startups and projects.",
    members: 234,
    totalAssets: "$5,800,000",
    type: "Technology"
  },
  {
    id: 4,
    name: "Community Housing Trust",
    description: "Affordable housing development and community land trust initiatives.",
    members: 67,
    totalAssets: "$3,200,000",
    type: "Housing"
  }
];

export default function Dashboard() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="space-y-2">
        <h1 className="text-3xl font-bold text-foreground">Dashboard</h1>
        <p className="text-muted-foreground">
          Discover and join cooperatives that align with your values and investment goals.
        </p>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">Total Cooperatives</CardTitle>
            <Building2 className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">{cooperatives.length}</div>
            <p className="text-xs text-muted-foreground">Active cooperatives available</p>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">Total Members</CardTitle>
            <Users className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">
              {cooperatives.reduce((sum, coop) => sum + coop.members, 0)}
            </div>
            <p className="text-xs text-muted-foreground">Across all cooperatives</p>
          </CardContent>
        </Card>

        <Card className="bg-gradient-card border-border">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-card-foreground">Total Assets</CardTitle>
            <TrendingUp className="h-4 w-4 text-coopifi-primary" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-card-foreground">$12.65M</div>
            <p className="text-xs text-muted-foreground">Combined asset value</p>
          </CardContent>
        </Card>
      </div>

      {/* Cooperatives List */}
      <div className="space-y-4">
        <h2 className="text-2xl font-semibold text-foreground">Available Cooperatives</h2>
        
        <div className="grid gap-6">
          {cooperatives.map((coop) => (
            <Card key={coop.id} className="bg-gradient-card border-border hover:border-coopifi-primary/50 transition-colors">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="space-y-1">
                    <CardTitle className="text-xl text-card-foreground">{coop.name}</CardTitle>
                    <CardDescription className="text-muted-foreground">
                      {coop.description}
                    </CardDescription>
                  </div>
                  <Button 
                    className="bg-coopifi-primary hover:bg-coopifi-primary/90 text-primary-foreground"
                  >
                    Join
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center gap-6">
                    <div className="flex items-center gap-2">
                      <Users className="h-4 w-4 text-coopifi-secondary" />
                      <span className="text-card-foreground">{coop.members} members</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <TrendingUp className="h-4 w-4 text-coopifi-secondary" />
                      <span className="text-card-foreground">{coop.totalAssets} assets</span>
                    </div>
                  </div>
                  <div className="px-2 py-1 bg-coopifi-accent rounded-md">
                    <span className="text-xs text-coopifi-secondary font-medium">{coop.type}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}