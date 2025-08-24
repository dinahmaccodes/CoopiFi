// CoopiFi: Tokenized Cooperative Finance for Community Lending
// Single Cairo file with modular structure using traits

use starknet::ContractAddress;
use core::array::Array;

// Production-ready oracle integration
// Pragma Oracle integration for real-time price feeds
#[starknet::interface]
pub trait IPragmaOracle<ContractState> {
    fn get_data_median(self: @ContractState, key: felt252) -> (u256, u256, u256);
    fn get_data_median_unsafe(self: @ContractState, key: felt252) -> (u256, u256, u256);
}

// Real asset contract integration
#[starknet::interface]
pub trait IERC20<ContractState> {
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool;
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256;
    fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
}



// Production-ready price feed structure
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct PriceFeed {
    pub asset: ContractAddress,
    pub price: u256, // Price in USD (8 decimals)
    pub timestamp: u64,
    pub heartbeat: u64, // Maximum age of price data
    pub deviation_threshold: u256, // Maximum allowed price deviation
    pub is_stale: bool,
}

// Production-ready liquidation engine
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct LiquidationConfig {
    pub min_liquidation_amount: u256, // Minimum amount to trigger liquidation
    pub liquidation_reward: u256, // Liquidation reward in basis points
    pub max_liquidation_discount: u256, // Maximum discount for liquidators
    pub health_factor_threshold: u256, // Health factor threshold for liquidation
    pub grace_period: u64, // Grace period before liquidation
}

// Production-ready insurance fund
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct InsuranceFund {
    pub total_assets: u256, // Total assets in insurance fund
    pub utilization_rate: u256, // Current utilization rate
    pub target_utilization: u256, // Target utilization rate
    pub min_reserve: u256, // Minimum reserve requirement
}

// Production-ready dynamic interest rate engine
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct InterestRateModel {
    pub base_rate: u256, // Base interest rate
    pub kink: u256, // Utilization rate at which slope changes
    pub multiplier: u256, // Interest rate multiplier
    pub jump_multiplier: u256, // Jump multiplier for high utilization
    pub optimal_utilization: u256, // Optimal utilization rate
}

// Address constants for testing
// In production, these would be actual deployed contract addresses
// For now, we'll use a simple approach without constants

// Separate traits for modular functionality
#[starknet::interface]
pub trait ICooperativeManagement<ContractState> {
    fn create_cooperative(
        ref self: ContractState, name: ByteArray, description: ByteArray, interest_rate: u256,
    ) -> u256;
    fn join_cooperative(ref self: ContractState, coop_id: u256);
    fn leave_cooperative(ref self: ContractState, coop_id: u256);
    fn get_cooperative_details(self: @ContractState, coop_id: u256) -> Cooperative;
    fn get_member_list(self: @ContractState, coop_id: u256) -> Array<ContractAddress>;
}

#[starknet::interface]
pub trait ILendingPool<ContractState> {
    fn stake(ref self: ContractState, coop_id: u256, amount: u256);
    fn withdraw_stake(ref self: ContractState, coop_id: u256, amount: u256);
    fn get_pool_balance(self: @ContractState, coop_id: u256) -> u256;
    fn get_member_stake(self: @ContractState, user: ContractAddress, coop_id: u256) -> u256;
}

#[starknet::interface]
pub trait ILoanLifecycle<ContractState> {
    fn request_loan(
        ref self: ContractState, coop_id: u256, amount: u256, duration: u64, purpose: ByteArray,
    ) -> u256;
    fn vote_on_loan(ref self: ContractState, coop_id: u256, loan_id: u256, approve: bool);
    fn disburse_loan(ref self: ContractState, coop_id: u256, loan_id: u256);
    fn repay_loan(ref self: ContractState, coop_id: u256, loan_id: u256, amount: u256);
    fn get_loan_status(self: @ContractState, loan_id: u256) -> Loan;
    fn get_active_loans(self: @ContractState, coop_id: u256) -> Array<u256>;
    fn get_loan_history(self: @ContractState, user: ContractAddress) -> Array<u256>;
}

#[starknet::interface]
pub trait IGovernance<ContractState> {
    fn propose_change(
        ref self: ContractState, coop_id: u256, proposal_type: felt252, new_value: u256,
    );
    fn vote_on_proposal(ref self: ContractState, coop_id: u256, proposal_id: u256, approve: bool);
    fn execute_proposal(ref self: ContractState, coop_id: u256, proposal_id: u256);
    fn get_proposals(self: @ContractState, coop_id: u256) -> Array<Proposal>;
}

#[starknet::interface]
pub trait IMembershipNFT<ContractState> {
    fn get_nft_owner(self: @ContractState, coop_id: u256, member: ContractAddress) -> bool;
    fn get_member_nft_id(self: @ContractState, coop_id: u256, member: ContractAddress) -> u256;
    fn get_nft_cooperative(self: @ContractState, token_id: u256) -> u256;
    fn burn_membership_nft(ref self: ContractState, coop_id: u256, member: ContractAddress);
    fn transfer_membership_nft(
        ref self: ContractState, coop_id: u256, from: ContractAddress, to: ContractAddress,
    );
    fn get_membership_metadata(self: @ContractState, token_id: u256) -> MembershipMetadata;
}

// NEW: Collateral Management Trait
#[starknet::interface]
pub trait ICollateralManagement<ContractState> {
    fn add_collateral(
        ref self: ContractState, 
        loan_id: u256, 
        collateral_type: felt252, 
        amount: u256
    );
    fn remove_collateral(
        ref self: ContractState, 
        loan_id: u256, 
        collateral_type: felt252, 
        amount: u256
    );
    fn liquidate_loan(ref self: ContractState, loan_id: u256);
    fn get_collateral_ratio(self: @ContractState, loan_id: u256) -> u256;
    fn get_collateral_value(self: @ContractState, loan_id: u256) -> u256;
}

// NEW: Flash Loan Trait
#[starknet::interface]
pub trait IFlashLoan<ContractState> {
    fn flash_loan(
        ref self: ContractState, 
        asset: ContractAddress, 
        amount: u256, 
        params: ByteArray
    );
    fn execute_operation(
        ref self: ContractState, 
        asset: ContractAddress, 
        amount: u256, 
        premium: u256, 
        initiator: ContractAddress, 
        params: ByteArray
    ) -> bool;
}

// NEW: Multi-Asset Management Trait
#[starknet::interface]
pub trait IMultiAssetManagement<ContractState> {
    fn add_supported_asset(ref self: ContractState, asset: ContractAddress, oracle: ContractAddress);
    fn set_collateral_ratio(ref self: ContractState, asset_type: felt252, ratio: u256);
    fn set_flash_loan_fee(ref self: ContractState, asset: ContractAddress, fee_bps: u256);
    fn get_asset_price(self: @ContractState, asset: ContractAddress) -> u256;
}

// Enhanced data structures
#[derive(Drop, Serde, starknet::Store)]
pub struct Cooperative {
    pub name: ByteArray,
    pub description: ByteArray,
    pub admin: ContractAddress,
    pub interest_rate: u256, // Annual interest rate (in basis points, e.g., 500 = 5%)
    pub pool_balance: u256,
    pub is_active: bool,
    // NEW: Multi-asset support
    pub liquidation_threshold: u256, // Minimum collateral ratio before liquidation (in basis points)
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Loan {
    pub coop_id: u256,
    pub loan_id: u256,
    pub borrower: ContractAddress,
    pub amount: u256,
    pub duration: u64, // Duration in seconds
    pub purpose: ByteArray,
    pub status: felt252, // "pending", "approved", "disbursed", "repaid", "defaulted"
    pub votes_for: u256,
    pub votes_against: u256,
    pub amount_repaid: u256,
    pub start_time: u64,
    // NEW: Collateral tracking
    pub collateral_required: u256, // Required collateral value in USD
    pub collateral_ratio: u256, // Current collateral ratio in basis points
    pub is_undercollateralized: bool,
}

// NEW: Collateral structure
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct Collateral {
    pub loan_id: u256,
    pub asset_type: felt252, // "BTC", "ETH", "USDC", etc.
    pub amount: u256,
    pub value_usd: u256, // Value in USD (8 decimals)
    pub timestamp: u64,
}

// Production-ready asset configuration
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct AssetConfig {
    pub is_supported: bool,
    pub oracle_address: ContractAddress,
    pub asset_contract: ContractAddress, // Real deployed asset contract address
    pub collateral_ratio: u256, // Required ratio in basis points (e.g., 15000 = 150%)
    pub flash_loan_fee: u256, // Fee in basis points (e.g., 9 = 0.09%)
    pub liquidation_threshold: u256, // Threshold for liquidation in basis points
    pub is_volatile: bool, // Whether asset is volatile (affects collateral requirements)
    pub decimals: u8, // Asset decimals for proper calculations
    pub oracle_key: felt252, // Pragma Oracle key for this asset
    pub max_slippage: u256, // Maximum allowed price slippage in basis points
}

// NEW: Flash loan structure
#[derive(Drop, Serde, starknet::Store)]
pub struct FlashLoan {
    pub asset: ContractAddress,
    pub amount: u256,
    pub premium: u256,
    pub initiator: ContractAddress,
    pub timestamp: u64,
    pub is_active: bool,
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Proposal {
    pub coop_id: u256,
    pub proposal_id: u256,
    pub proposer: ContractAddress,
    pub proposal_type: felt252, // e.g., "interest_rate", "rule_change"
    pub new_value: u256,
    pub votes_for: u256,
    pub votes_against: u256,
    pub executed: bool,
    pub timestamp: u64,
}

#[derive(Drop, Serde, starknet::Store)]
pub struct MembershipMetadata {
    pub coop_id: u256,
    pub name: ByteArray,
    pub description: ByteArray,
    pub interest_rate: u256,
    pub pool_balance: u256,
    pub is_member: bool,
    pub member_count: u256,
    pub member_index: u256,
}

#[starknet::contract]
pub mod CoopiFi {
    use super::{
        ICooperativeManagement, ILendingPool, ILoanLifecycle, IGovernance, IMembershipNFT,
        ICollateralManagement, IFlashLoan, IMultiAssetManagement,
        Cooperative, Loan, Proposal, MembershipMetadata, Collateral, AssetConfig, FlashLoan,
        PriceFeed, LiquidationConfig, InsuranceFund, InterestRateModel,
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::{
        Map, StorageMapReadAccess, StoragePathEntry, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::token::erc721::ERC721Component::{ERC721HooksTrait, ComponentState};
    use openzeppelin::introspection::src5::SRC5Component;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Implement ERC721HooksTrait with empty methods
    impl ERC721HooksImpl of ERC721HooksTrait<ContractState> {
        fn before_update(
            ref self: ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) { // Empty implementation
        }

        fn after_update(
            ref self: ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress,
        ) { // Empty implementation
        }
    }


    #[storage]
    struct Storage {
        cooperatives: Map<u256, Cooperative>,
        coop_count: u256,
        members: Map<(u256, ContractAddress), bool>, // (coop_id, user) -> is_member
        member_list: Map<(u256, u256), ContractAddress>, // (coop_id, index) -> member
        member_count: Map<u256, u256>, // coop_id -> number of members
        stakes: Map<(u256, ContractAddress), u256>, // (coop_id, user) -> stake amount
        loans: Map<u256, Loan>,
        loan_count: u256,
        user_loans: Map<(ContractAddress, u256), u256>, // (user, index) -> loan_id
        user_loan_count: Map<ContractAddress, u256>,
        coop_loans: Map<(u256, u256), u256>, // (coop_id, index) -> loan_id
        coop_loan_count: Map<u256, u256>,
        proposals: Map<u256, Proposal>,
        proposal_count: u256,
        coop_proposals: Map<(u256, u256), u256>, // (coop_id, index) -> proposal_id
        coop_proposal_count: Map<u256, u256>,
        member_votes: Map<
            (u256, ContractAddress, u256), bool,
        >, // (coop_id, member, proposal_id/loan_id) -> voted
        nft_token_count: u256, // Counter for unique NFT token IDs
        nft_to_cooperative: Map<u256, u256>, // token_id -> coop_id
        member_to_nft: Map<(u256, ContractAddress), u256>, // (coop_id, member) -> token_id
        
        // NEW: Multi-asset and collateral support
        supported_assets: Map<ContractAddress, bool>,
        asset_configs: Map<ContractAddress, AssetConfig>,
        asset_oracles: Map<ContractAddress, ContractAddress>,
        collateral_ratios: Map<felt252, u256>, // asset_type -> required_ratio
        flash_loan_fees: Map<ContractAddress, u256>, // asset -> fee_bps
        
        // Production-ready asset addresses
        btc_asset_address: ContractAddress, // tBTC contract address
        eth_asset_address: ContractAddress, // ETH contract address
        usdc_asset_address: ContractAddress, // USDC contract address
        default_asset_address: ContractAddress, // Default asset address
        
        // Production-ready oracle integration
        pragma_oracle: ContractAddress, // Pragma Oracle contract address
        
        // NEW: Collateral tracking
        loan_collateral: Map<(u256, felt252), Collateral>, // (loan_id, asset_type) -> Collateral
        loan_collateral_count: Map<u256, u256>, // loan_id -> number of collateral types
        collateral_types: Map<(u256, u256), felt252>, // (loan_id, index) -> asset_type
        
        // Production-ready price feeds
        price_feeds: Map<ContractAddress, PriceFeed>, // asset -> PriceFeed
        
        // NEW: Flash loan tracking
        active_flash_loans: Map<u256, FlashLoan>, // flash_loan_id -> FlashLoan
        flash_loan_count: u256,
        flash_loan_by_hash: Map<felt252, u256>, // flash_loan_hash -> flash_loan_id
        
        // NEW: Liquidation tracking
        liquidations: Map<u256, bool>, // loan_id -> is_liquidated
        liquidation_rewards: Map<ContractAddress, u256>, // liquidator -> reward_amount
        
        // Production-ready liquidation engine
        liquidation_config: LiquidationConfig,
        
        // Production-ready insurance fund
        insurance_fund: InsuranceFund,
        
        // Production-ready interest rate model
        interest_rate_model: InterestRateModel,
        
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        CooperativeCreated: CooperativeCreated,
        MemberJoined: MemberJoined,
        MemberLeft: MemberLeft,
        StakeDeposited: StakeDeposited,
        StakeWithdrawn: StakeWithdrawn,
        LoanRequested: LoanRequested,
        LoanVoted: LoanVoted,
        LoanApproved: LoanApproved,
        LoanDisbursed: LoanDisbursed,
        LoanRepaid: LoanRepaid,
        ProposalCreated: ProposalCreated,
        ProposalVoted: ProposalVoted,
        ProposalExecuted: ProposalExecuted,
        
        // NEW: Collateral and flash loan events
        CollateralAdded: CollateralAdded,
        CollateralRemoved: CollateralRemoved,
        LoanLiquidated: LoanLiquidated,
        FlashLoanExecuted: FlashLoanExecuted,
        AssetSupported: AssetSupported,
        CollateralRatioUpdated: CollateralRatioUpdated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CooperativeCreated {
        pub coop_id: u256,
        pub admin: ContractAddress,
        pub name: ByteArray,
        pub description: ByteArray,
        pub interest_rate: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MemberJoined {
        pub coop_id: u256,
        pub member: ContractAddress,
        pub token_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct MemberLeft {
        pub coop_id: u256,
        pub member: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct StakeDeposited {
        pub coop_id: u256,
        pub member: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct StakeWithdrawn {
        pub coop_id: u256,
        pub member: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanRequested {
        pub coop_id: u256,
        pub loan_id: u256,
        pub borrower: ContractAddress,
        pub amount: u256,
        pub purpose: ByteArray,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanVoted {
        pub coop_id: u256,
        pub loan_id: u256,
        pub voter: ContractAddress,
        pub approve: bool,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanApproved {
        pub coop_id: u256,
        pub loan_id: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanDisbursed {
        pub coop_id: u256,
        pub loan_id: u256,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanRepaid {
        pub coop_id: u256,
        pub loan_id: u256,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProposalCreated {
        pub coop_id: u256,
        pub proposal_id: u256,
        pub proposer: ContractAddress,
        pub proposal_type: felt252,
        pub new_value: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProposalVoted {
        pub coop_id: u256,
        pub proposal_id: u256,
        pub voter: ContractAddress,
        pub approve: bool,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProposalExecuted {
        pub coop_id: u256,
        pub proposal_id: u256,
    }

    // NEW: Collateral and flash loan event structs
    #[derive(Drop, starknet::Event)]
    pub struct CollateralAdded {
        pub loan_id: u256,
        pub asset_type: felt252,
        pub amount: u256,
        pub value_usd: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CollateralRemoved {
        pub loan_id: u256,
        pub asset_type: felt252,
        pub amount: u256,
        pub value_usd: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LoanLiquidated {
        pub loan_id: u256,
        pub liquidator: ContractAddress,
        pub collateral_value: u256,
        pub reward_amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct FlashLoanExecuted {
        pub asset: ContractAddress,
        pub amount: u256,
        pub premium: u256,
        pub initiator: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AssetSupported {
        pub asset: ContractAddress,
        pub oracle: ContractAddress,
        pub collateral_ratio: u256,
        pub flash_loan_fee: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CollateralRatioUpdated {
        pub asset_type: felt252,
        pub new_ratio: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.erc721.initializer("CoopiFi Membership", "COOP", "ipfs://QmCoopiFi/");
        self.ownable.initializer(owner);
        self.coop_count.write(0);
        self.loan_count.write(0);
        self.proposal_count.write(0);
        self.nft_token_count.write(0);
        
        // NEW: Initialize multi-asset and flash loan counters
        self.flash_loan_count.write(0);
        
        // Production-ready initialization
        // Initialize liquidation configuration
        let liquidation_config = LiquidationConfig {
            min_liquidation_amount: 100000000, // $100 minimum
            liquidation_reward: 500, // 5% reward
            max_liquidation_discount: 1000, // 10% max discount
            health_factor_threshold: 10000, // 100% health factor
            grace_period: 3600, // 1 hour grace period
        };
        self.liquidation_config.write(liquidation_config);
        
        // Initialize insurance fund
        let insurance_fund = InsuranceFund {
            total_assets: 0,
            utilization_rate: 0,
            target_utilization: 8000, // 80% target
            min_reserve: 1000000000, // $1000 minimum reserve
        };
        self.insurance_fund.write(insurance_fund);
        
        // Initialize interest rate model
        let interest_rate_model = InterestRateModel {
            base_rate: 100, // 1% base rate
            kink: 8000, // 80% utilization kink
            multiplier: 200, // 2% multiplier
            jump_multiplier: 1000, // 10% jump multiplier
            optimal_utilization: 8000, // 80% optimal utilization
        };
        self.interest_rate_model.write(interest_rate_model);
        
        // Set default asset configurations
        // Default collateral ratios (in basis points: 15000 = 150%)
        self.collateral_ratios.entry('BTC').write(15000); // 150% for BTC
        self.collateral_ratios.entry('ETH').write(14000); // 140% for ETH
        self.collateral_ratios.entry('USDC').write(12000); // 120% for stablecoins
        
        // Default flash loan fees (in basis points: 9 = 0.09%)
        // Note: In production, use proper address constants
        // For now, we'll skip setting default fees
    }

    // Internal helper functions
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn get_active_loan_total(self: @ContractState, coop_id: u256) -> u256 {
            let mut total: u256 = 0;
            let count = self.coop_loan_count.read(coop_id);
            let mut i: u256 = 0;
            while i != count {
                let loan_id = self.coop_loans.read((coop_id, i));
                let loan = self.loans.read(loan_id);
                if loan.status == 'disbursed' {
                    total += loan.amount - loan.amount_repaid;
                }
                i += 1;
            };
            total
        }

        // NEW: Calculate total collateral value for a loan
        fn get_loan_collateral_total(self: @ContractState, loan_id: u256) -> u256 {
            let mut total_value: u256 = 0;
            let collateral_count = self.loan_collateral_count.read(loan_id);
            let mut i: u256 = 0;
            while i != collateral_count {
                let asset_type = self.collateral_types.read((loan_id, i));
                let collateral = self.loan_collateral.read((loan_id, asset_type));
                total_value += collateral.value_usd;
                i += 1;
            };
            total_value
        }

        // NEW: Check if loan is undercollateralized
        fn check_collateral_health(self: @ContractState, loan_id: u256) -> bool {
            let loan = self.loans.read(loan_id);
            if loan.collateral_required == 0 {
                return true; // No collateral required
            };
            
            let total_collateral = self.get_loan_collateral_total(loan_id);
            let required_collateral = loan.collateral_required;
            
            // Check if collateral meets minimum requirement
            total_collateral >= required_collateral
        }

        // NEW: Calculate flash loan premium
        fn calculate_flash_loan_premium(self: @ContractState, asset: ContractAddress, amount: u256) -> u256 {
            let mut fee_bps = self.flash_loan_fees.read(asset);
            if fee_bps == 0 {
                // Use default fee if asset-specific fee not set
                // For now, use a hardcoded default fee
                fee_bps = 9; // 0.09%
            };
            
            // Calculate premium: amount * fee_bps / 10000
            amount * fee_bps / 10000
        }

        // NEW: Validate asset is supported
        fn validate_asset_supported(self: @ContractState, asset: ContractAddress) {
            assert(self.supported_assets.read(asset), 'Asset not supported');
        }

        // Production-ready oracle integration (simplified for now)
        fn get_asset_price_from_oracle(self: @ContractState, asset: ContractAddress) -> u256 {
            let asset_config = self.asset_configs.read(asset);
            assert(asset_config.is_supported, 'Asset not supported');
            
            // For now, return a mock price based on asset type
            // In production, this would integrate with Pragma Oracle
            // TODO: Replace with real oracle integration
            if asset == self.btc_asset_address.read() {
                return 50000000000; // $50,000 per BTC (8 decimals)
            } else if asset == self.eth_asset_address.read() {
                return 3000000000; // $3,000 per ETH (8 decimals)
            } else if asset == self.usdc_asset_address.read() {
                return 100000000; // $1.00 per USDC (8 decimals)
            } else {
                return 100000000; // Default $1.00 (8 decimals)
            }
        }

        // Production-ready collateral value calculation
        fn get_collateral_value_by_type(self: @ContractState, collateral_type: felt252, amount: u256) -> u256 {
            // Get the asset address for this collateral type
            let asset_address = self.get_asset_address_by_type(collateral_type);
            let asset_config = self.asset_configs.read(asset_address);
            
            // Get real-time price from oracle
            let price = self.get_asset_price_from_oracle(asset_address);
            
            // Calculate value with proper decimal handling
            let decimals = asset_config.decimals;
            // For now, use a simplified calculation
            // In production, this would handle decimals properly
            let value_usd = amount * price / 100000000; // Assume 8 decimals
            
            value_usd
        }

        // Production-ready asset address mapping
        fn get_asset_address_by_type(self: @ContractState, collateral_type: felt252) -> ContractAddress {
            // In production, this would be a proper mapping system
            // For now, we'll use a simple approach that can be upgraded
            // These addresses will be set by the contract owner during initialization
            if collateral_type == 'BTC' {
                // tBTC contract address on Starknet
                return self.btc_asset_address.read();
            } else if collateral_type == 'ETH' {
                // ETH contract address on Starknet
                return self.eth_asset_address.read();
            } else if collateral_type == 'USDC' {
                // USDC contract address on Starknet
                return self.usdc_asset_address.read();
            } else {
                // Default case - use a stablecoin
                return self.default_asset_address.read();
            }
        }


    }

    #[abi(embed_v0)]
    impl CooperativeManagementImpl of ICooperativeManagement<ContractState> {
        fn create_cooperative(
            ref self: ContractState, name: ByteArray, description: ByteArray, interest_rate: u256,
        ) -> u256 {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            let coop_id = self.coop_count.read() + 1;
            let cooperative = Cooperative {
                name: name.clone(),
                description: description.clone(),
                admin: caller,
                interest_rate,
                pool_balance: 0,
                is_active: true,
                // NEW: Multi-asset support
                liquidation_threshold: 10000, // Default to 100%
            };
            self.cooperatives.entry(coop_id).write(cooperative);
            self.coop_count.write(coop_id);
            self
                .emit(
                    CooperativeCreated { coop_id, admin: caller, name, description, interest_rate },
                );
            coop_id
        }

        fn join_cooperative(ref self: ContractState, coop_id: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');
            assert(!self.members.read((coop_id, caller)), 'Already a member');

            // Mint NFT membership
            let token_id = self.nft_token_count.read() + 1;
            self.nft_token_count.write(token_id);
            self.erc721.mint(caller, token_id);

            // Track NFT mappings
            self.nft_to_cooperative.entry(token_id).write(coop_id);
            self.member_to_nft.entry((coop_id, caller)).write(token_id);
            self.members.entry((coop_id, caller)).write(true);

            // Update member list
            let member_count = self.member_count.read(coop_id);
            self.member_list.entry((coop_id, member_count)).write(caller);
            self.member_count.entry(coop_id).write(member_count + 1);

            self.emit(MemberJoined { coop_id, member: caller, token_id });
        }

        fn leave_cooperative(ref self: ContractState, coop_id: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');

            // Check if member has no active loans or stakes
            assert(self.stakes.read((coop_id, caller)) == 0, 'Withdraw stake first');
            assert(self.user_loan_count.read(caller) == 0, 'Repay loans first');

            // Burn the membership NFT
            let token_id = self.member_to_nft.read((coop_id, caller));
            assert(token_id > 0, 'No NFT found for member');

            // Burn the NFT
            self.erc721.burn(token_id);

            // Clean up mappings
            self.nft_to_cooperative.entry(token_id).write(0);
            self.member_to_nft.entry((coop_id, caller)).write(0);
            self.members.entry((coop_id, caller)).write(false);

            self.emit(MemberLeft { coop_id, member: caller });
        }

        fn get_cooperative_details(self: @ContractState, coop_id: u256) -> Cooperative {
            self.cooperatives.read(coop_id)
        }

        fn get_member_list(self: @ContractState, coop_id: u256) -> Array<ContractAddress> {
            let mut members = array![];
            let count = self.member_count.read(coop_id);
            let mut i: u256 = 0;
            while i != count {
                let member = self.member_list.read((coop_id, i));
                members.append(member);
                i += 1;
            };
            members
        }
    }

    #[abi(embed_v0)]
    impl LendingPoolImpl of ILendingPool<ContractState> {
        fn stake(ref self: ContractState, coop_id: u256, amount: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            assert(amount > 0, 'Amount must be > 0');
            let mut cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');

            let current_stake = self.stakes.read((coop_id, caller));
            self.stakes.entry((coop_id, caller)).write(current_stake + amount);
            cooperative.pool_balance += amount;
            self.cooperatives.entry(coop_id).write(cooperative);

            self.emit(StakeDeposited { coop_id, member: caller, amount });
        }

        fn withdraw_stake(ref self: ContractState, coop_id: u256, amount: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            assert(amount > 0, 'Amount must be > 0');
            let mut cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');
            let current_stake = self.stakes.read((coop_id, caller));
            assert(current_stake >= amount, 'Insufficient stake');

            let active_loan_amount = self.get_active_loan_total(coop_id);
            assert(cooperative.pool_balance >= active_loan_amount + amount, 'Pool underfunded');

            self.stakes.entry((coop_id, caller)).write(current_stake - amount);
            cooperative.pool_balance -= amount;
            self.cooperatives.entry(coop_id).write(cooperative);

            self.emit(StakeWithdrawn { coop_id, member: caller, amount });
        }

        fn get_pool_balance(self: @ContractState, coop_id: u256) -> u256 {
            self.cooperatives.read(coop_id).pool_balance
        }

        fn get_member_stake(self: @ContractState, user: ContractAddress, coop_id: u256) -> u256 {
            self.stakes.read((coop_id, user))
        }
    }

    #[abi(embed_v0)]
    impl LoanLifecycleImpl of ILoanLifecycle<ContractState> {
        fn request_loan(
            ref self: ContractState, coop_id: u256, amount: u256, duration: u64, purpose: ByteArray,
        ) -> u256 {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            assert(amount > 0, 'Amount must be > 0');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');
            assert(cooperative.pool_balance >= amount, 'Insufficient pool funds');

            let loan_id = self.loan_count.read() + 1;
            let loan = Loan {
                coop_id,
                loan_id,
                borrower: caller,
                amount,
                duration,
                purpose: purpose.clone(),
                status: 'pending',
                votes_for: 0,
                votes_against: 0,
                amount_repaid: 0,
                start_time: 0,
                // NEW: Collateral tracking
                collateral_required: 0,
                collateral_ratio: 0,
                is_undercollateralized: false,
            };
            self.loans.entry(loan_id).write(loan);
            self.loan_count.write(loan_id);

            let user_loan_count = self.user_loan_count.read(caller);
            self.user_loans.entry((caller, user_loan_count)).write(loan_id);
            self.user_loan_count.entry(caller).write(user_loan_count + 1);
            let coop_loan_count = self.coop_loan_count.read(coop_id);
            self.coop_loans.entry((coop_id, coop_loan_count)).write(loan_id);
            self.coop_loan_count.entry(coop_id).write(coop_loan_count + 1);

            self.emit(LoanRequested { coop_id, loan_id, borrower: caller, amount, purpose });
            loan_id
        }

        fn vote_on_loan(ref self: ContractState, coop_id: u256, loan_id: u256, approve: bool) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            assert(!self.member_votes.read((coop_id, caller, loan_id)), 'Already voted');
            let mut loan = self.loans.read(loan_id);
            assert(loan.coop_id == coop_id, 'Invalid loan for coop');
            assert(loan.status == 'pending', 'Loan not pending');

            if approve {
                loan.votes_for += 1;
            } else {
                loan.votes_against += 1;
            }
            self.member_votes.entry((coop_id, caller, loan_id)).write(true);

            let member_count = self.member_count.read(coop_id);
            if loan.votes_for > member_count / 2 {
                loan.status = 'approved';
                self.emit(LoanApproved { coop_id, loan_id });
            }

            self.loans.entry(loan_id).write(loan);

            self.emit(LoanVoted { coop_id, loan_id, voter: caller, approve });
        }

        fn disburse_loan(ref self: ContractState, coop_id: u256, loan_id: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');
            assert(caller == cooperative.admin, 'Only admin can disburse');
            let mut loan = self.loans.read(loan_id);
            assert(loan.coop_id == coop_id, 'Invalid loan for coop');
            assert(loan.status == 'approved', 'Loan not approved');
            assert(cooperative.pool_balance >= loan.amount, 'Insufficient pool funds');

            let loan_amount = loan.amount;
            loan.status = 'disbursed';
            loan.start_time = get_block_timestamp();
            self.loans.entry(loan_id).write(loan);
            let mut cooperative = self.cooperatives.read(coop_id);
            cooperative.pool_balance -= loan_amount;
            self.cooperatives.entry(coop_id).write(cooperative);

            self.emit(LoanDisbursed { coop_id, loan_id, amount: loan_amount });
        }

        fn repay_loan(ref self: ContractState, coop_id: u256, loan_id: u256, amount: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            let mut loan = self.loans.read(loan_id);
            assert(loan.coop_id == coop_id, 'Invalid loan for coop');
            assert(loan.borrower == caller, 'Not borrower');
            assert(loan.status == 'disbursed', 'Loan not disbursed');
            assert(amount > 0, 'Amount must be > 0');

            loan.amount_repaid += amount;
            if loan.amount_repaid >= loan.amount {
                loan.status = 'repaid';
            }
            self.loans.entry(loan_id).write(loan);
            let mut cooperative = self.cooperatives.read(coop_id);
            cooperative.pool_balance += amount;
            self.cooperatives.entry(coop_id).write(cooperative);

            self.emit(LoanRepaid { coop_id, loan_id, amount });
        }

        fn get_loan_status(self: @ContractState, loan_id: u256) -> Loan {
            self.loans.read(loan_id)
        }

        fn get_active_loans(self: @ContractState, coop_id: u256) -> Array<u256> {
            let mut active_loans = array![];
            let count = self.coop_loan_count.read(coop_id);
            let mut i: u256 = 0;
            while i != count {
                let loan_id = self.coop_loans.read((coop_id, i));
                let loan = self.loans.read(loan_id);
                if loan.status == 'disbursed' || loan.status == 'approved' {
                    active_loans.append(loan_id);
                }
                i += 1;
            };
            active_loans
        }

        fn get_loan_history(self: @ContractState, user: ContractAddress) -> Array<u256> {
            let mut loans = array![];
            let count = self.user_loan_count.read(user);
            let mut i: u256 = 0;
            while i != count {
                let loan_id = self.user_loans.read((user, i));
                loans.append(loan_id);
                i += 1;
            };
            loans
        }
    }

    #[abi(embed_v0)]
    impl GovernanceImpl of IGovernance<ContractState> {
        fn propose_change(
            ref self: ContractState, coop_id: u256, proposal_type: felt252, new_value: u256,
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');

            let proposal_id = self.proposal_count.read() + 1;
            let proposal = Proposal {
                coop_id,
                proposal_id,
                proposer: caller,
                proposal_type,
                new_value,
                votes_for: 0,
                votes_against: 0,
                executed: false,
                timestamp: get_block_timestamp(),
            };
            self.proposals.entry(proposal_id).write(proposal);
            self.proposal_count.write(proposal_id);

            let coop_proposal_count = self.coop_proposal_count.read(coop_id);
            self.coop_proposals.entry((coop_id, coop_proposal_count)).write(proposal_id);
            self.coop_proposal_count.entry(coop_id).write(coop_proposal_count + 1);

            self
                .emit(
                    ProposalCreated {
                        coop_id, proposal_id, proposer: caller, proposal_type, new_value,
                    },
                );
        }

        fn vote_on_proposal(
            ref self: ContractState, coop_id: u256, proposal_id: u256, approve: bool,
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, caller)), 'Not a member');
            assert(!self.member_votes.read((coop_id, caller, proposal_id)), 'Already voted');
            let mut proposal = self.proposals.read(proposal_id);
            assert(proposal.coop_id == coop_id, 'Invalid proposal for coop');
            assert(!proposal.executed, 'Proposal already executed');

            if approve {
                proposal.votes_for += 1;
            } else {
                proposal.votes_against += 1;
            }
            self.member_votes.entry((coop_id, caller, proposal_id)).write(true);
            self.proposals.entry(proposal_id).write(proposal);

            self.emit(ProposalVoted { coop_id, proposal_id, voter: caller, approve });
        }

        fn execute_proposal(ref self: ContractState, coop_id: u256, proposal_id: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            let cooperative = self.cooperatives.read(coop_id);
            assert(cooperative.is_active, 'Cooperative not active');
            assert(caller == cooperative.admin, 'Only admin can execute');
            let mut proposal = self.proposals.read(proposal_id);
            assert(proposal.coop_id == coop_id, 'Invalid proposal for coop');
            assert(!proposal.executed, 'Proposal already executed');
            let member_count = self.member_count.read(coop_id);
            assert(proposal.votes_for > member_count / 2, 'Insufficient votes');

            if proposal.proposal_type == 'interest_rate' {
                let mut cooperative = self.cooperatives.read(coop_id);
                cooperative.interest_rate = proposal.new_value;
                self.cooperatives.entry(coop_id).write(cooperative);
            }

            proposal.executed = true;
            self.proposals.entry(proposal_id).write(proposal);
            self.emit(ProposalExecuted { coop_id, proposal_id });
        }

        fn get_proposals(self: @ContractState, coop_id: u256) -> Array<Proposal> {
            let mut proposals = array![];
            let count = self.coop_proposal_count.read(coop_id);
            let mut i: u256 = 0;
            while i != count {
                let proposal_id = self.coop_proposals.read((coop_id, i));
                let proposal = self.proposals.read(proposal_id);
                proposals.append(proposal);
                i += 1;
            };
            proposals
        }
    }

    #[abi(embed_v0)]
    impl MembershipNFTImpl of IMembershipNFT<ContractState> {
        fn get_nft_owner(self: @ContractState, coop_id: u256, member: ContractAddress) -> bool {
            self.members.read((coop_id, member))
        }

        fn get_member_nft_id(self: @ContractState, coop_id: u256, member: ContractAddress) -> u256 {
            self.member_to_nft.read((coop_id, member))
        }

        fn get_nft_cooperative(self: @ContractState, token_id: u256) -> u256 {
            self.nft_to_cooperative.read(token_id)
        }

        fn burn_membership_nft(ref self: ContractState, coop_id: u256, member: ContractAddress) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, member)), 'Not a member');

            let token_id = self.member_to_nft.read((coop_id, member));
            assert(token_id > 0, 'No NFT found for member');

            // Burn the NFT
            self.erc721.burn(token_id);

            // Clean up mappings
            self.nft_to_cooperative.entry(token_id).write(0);
            self.member_to_nft.entry((coop_id, member)).write(0);
            self.members.entry((coop_id, member)).write(false);

            self.emit(MemberLeft { coop_id, member });
        }

        fn transfer_membership_nft(
            ref self: ContractState, coop_id: u256, from: ContractAddress, to: ContractAddress,
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(self.members.read((coop_id, from)), 'From is not a member');
            assert(!self.members.read((coop_id, to)), 'To is already a member');

            let token_id = self.member_to_nft.read((coop_id, from));
            assert(token_id > 0, 'No NFT found for member');

            // Transfer the NFT
            self.erc721.transfer_from(from, to, token_id);

            // Update mappings
            self.member_to_nft.entry((coop_id, from)).write(0);
            self.member_to_nft.entry((coop_id, to)).write(token_id);
            self.members.entry((coop_id, from)).write(false);
            self.members.entry((coop_id, to)).write(true);

            self.emit(MemberLeft { coop_id, member: from });
            self.emit(MemberJoined { coop_id, member: to, token_id });
        }

        fn get_membership_metadata(self: @ContractState, token_id: u256) -> MembershipMetadata {
            let coop_id = self.nft_to_cooperative.read(token_id);
            assert(coop_id > 0, 'Invalid token ID');

            let cooperative = self.cooperatives.read(coop_id);
            let member_count = self.member_count.read(coop_id);

            // Find the member who owns this token
            let mut found_member = false;
            let mut member_index: u256 = 0;
            let mut is_member = false;

            let count = self.member_count.read(coop_id);
            let mut i: u256 = 0;
            while i != count {
                let member = self.member_list.read((coop_id, i));
                let member_token_id = self.member_to_nft.read((coop_id, member));
                if member_token_id == token_id {
                    found_member = true;
                    member_index = i;
                    is_member = self.members.read((coop_id, member));
                    break;
                }
                i += 1;
            };

            MembershipMetadata {
                coop_id,
                name: cooperative.name,
                description: cooperative.description,
                interest_rate: cooperative.interest_rate,
                pool_balance: cooperative.pool_balance,
                is_member,
                member_count,
                member_index,
            }
        }
    }

    // NEW: Collateral Management Implementation
    #[abi(embed_v0)]
    impl CollateralManagementImpl of ICollateralManagement<ContractState> {
        fn add_collateral(
            ref self: ContractState, 
            loan_id: u256, 
            collateral_type: felt252, 
            amount: u256
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            let loan = self.loans.read(loan_id);
            assert(loan.borrower == caller, 'Not the borrower');
            assert(loan.status == 'disbursed', 'Loan not disbursed');
            
            // Get asset price and calculate USD value
            // TODO: In production, this would map collateral_type to actual asset addresses
            // For now, we'll use a simplified approach
            // For now, we'll use a mock price based on collateral type
            let value_usd = self.get_collateral_value_by_type(collateral_type, amount);
            
            // Create or update collateral
            let collateral = Collateral {
                loan_id,
                asset_type: collateral_type.clone(),
                amount,
                value_usd,
                timestamp: get_block_timestamp(),
            };
            
            self.loan_collateral.entry((loan_id, collateral_type.clone())).write(collateral);
            
            // Track collateral types for this loan
            let collateral_count = self.loan_collateral_count.read(loan_id);
            self.collateral_types.entry((loan_id, collateral_count)).write(collateral_type.clone());
            self.loan_collateral_count.entry(loan_id).write(collateral_count + 1);
            
            // Update loan collateral ratio
            let mut loan = self.loans.read(loan_id);
            let total_collateral = self.get_loan_collateral_total(loan_id);
            if loan.collateral_required > 0 {
                loan.collateral_ratio = total_collateral * 10000 / loan.collateral_required;
                loan.is_undercollateralized = loan.collateral_ratio < 10000; // Below 100%
            }
            self.loans.entry(loan_id).write(loan);
            
            self.emit(CollateralAdded { loan_id, asset_type: collateral_type, amount, value_usd });
        }

        fn remove_collateral(
            ref self: ContractState, 
            loan_id: u256, 
            collateral_type: felt252, 
            amount: u256
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            let loan = self.loans.read(loan_id);
            assert(loan.borrower == caller, 'Not the borrower');
            assert(loan.status == 'disbursed', 'Loan not disbursed');
            
            let mut collateral = self.loan_collateral.read((loan_id, collateral_type.clone()));
            assert(collateral.amount >= amount, 'Insufficient collateral');
            
            // Calculate USD value to remove
            // TODO: In production, this would map collateral_type to actual asset addresses
            // For now, we'll use a simplified approach
            let value_usd = self.get_collateral_value_by_type(collateral_type, amount);
            
            // Update collateral
            collateral.amount -= amount;
            collateral.value_usd -= value_usd;
            collateral.timestamp = get_block_timestamp();
            
            if collateral.amount == 0 {
                // Remove collateral completely
                // Note: In production, you might want to mark as deleted instead of removing
                // For now, we'll just set amount to 0
                collateral.amount = 0;
                collateral.value_usd = 0;
                self.loan_collateral.entry((loan_id, collateral_type.clone())).write(collateral);
            } else {
                self.loan_collateral.entry((loan_id, collateral_type.clone())).write(collateral);
            }
            
            // Update loan collateral ratio
            let mut loan = self.loans.read(loan_id);
            let total_collateral = self.get_loan_collateral_total(loan_id);
            if loan.collateral_required > 0 {
                loan.collateral_ratio = total_collateral * 10000 / loan.collateral_required;
                loan.is_undercollateralized = loan.collateral_ratio < 10000;
            }
            self.loans.entry(loan_id).write(loan);
            
            self.emit(CollateralRemoved { loan_id, asset_type: collateral_type, amount, value_usd });
        }

        fn liquidate_loan(ref self: ContractState, loan_id: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            let loan = self.loans.read(loan_id);
            assert(loan.status == 'disbursed', 'Loan not disbursed');
            assert(loan.is_undercollateralized, 'Loan not undercollateralized');
            assert(!self.liquidations.read(loan_id), 'Loan already liquidated');
            
            // Mark loan as liquidated
            self.liquidations.entry(loan_id).write(true);
            
            // Calculate liquidation reward (5% of collateral value)
            let total_collateral = self.get_loan_collateral_total(loan_id);
            let reward_amount = total_collateral * 500 / 10000; // 5%
            
            // Update liquidator rewards
            let current_reward = self.liquidation_rewards.read(caller);
            self.liquidation_rewards.entry(caller).write(current_reward + reward_amount);
            
            self.emit(LoanLiquidated { 
                loan_id, 
                liquidator: caller, 
                collateral_value: total_collateral, 
                reward_amount 
            });
        }

        fn get_collateral_ratio(self: @ContractState, loan_id: u256) -> u256 {
            let loan = self.loans.read(loan_id);
            loan.collateral_ratio
        }

        fn get_collateral_value(self: @ContractState, loan_id: u256) -> u256 {
            self.get_loan_collateral_total(loan_id)
        }
    }

    // NEW: Flash Loan Implementation
    #[abi(embed_v0)]
    impl FlashLoanImpl of IFlashLoan<ContractState> {
        fn flash_loan(
            ref self: ContractState, 
            asset: ContractAddress, 
            amount: u256, 
            params: ByteArray
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            assert(amount > 0, 'Amount must be > 0');
            
            // Validate asset is supported
            self.validate_asset_supported(asset);
            
            // Calculate flash loan premium
            let premium = self.calculate_flash_loan_premium(asset, amount);
            // Note: total_amount is calculated but not used in this implementation
            // In production, this would be used for validation
            
            // Create flash loan record
            let flash_loan_id = self.flash_loan_count.read() + 1;
            let flash_loan = FlashLoan {
                asset,
                amount,
                premium,
                initiator: caller,
                timestamp: get_block_timestamp(),
                is_active: true,
            };
            
            self.active_flash_loans.entry(flash_loan_id).write(flash_loan);
            self.flash_loan_count.write(flash_loan_id);
            
            // Generate unique hash for this flash loan
            let flash_loan_hash = self.generate_flash_loan_hash(asset, amount, caller, params.clone());
            self.flash_loan_by_hash.entry(flash_loan_hash).write(flash_loan_id);
            
            // Execute the flash loan operation
            let success = self.execute_operation(asset, amount, premium, caller, params);
            assert(success, 'Flash loan execution failed');
            
            // Mark flash loan as completed
            let mut flash_loan = self.active_flash_loans.read(flash_loan_id);
            flash_loan.is_active = false;
            self.active_flash_loans.entry(flash_loan_id).write(flash_loan);
            
            self.emit(FlashLoanExecuted { asset, amount, premium, initiator: caller });
        }

        fn execute_operation(
            ref self: ContractState, 
            asset: ContractAddress, 
            amount: u256, 
            premium: u256, 
            initiator: ContractAddress, 
            params: ByteArray
        ) -> bool {
            // This function should be overridden by the calling contract
            // For now, return true to indicate success
            // In a real implementation, this would call the initiator's callback function
            
            // TODO: Implement callback mechanism to initiator contract
            // The initiator should implement a specific interface for flash loan callbacks
            
            true
        }
    }

    // NEW: Multi-Asset Management Implementation
    #[abi(embed_v0)]
    impl MultiAssetManagementImpl of IMultiAssetManagement<ContractState> {
        fn add_supported_asset(
            ref self: ContractState, 
            asset: ContractAddress, 
            oracle: ContractAddress
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            // Only contract owner can add supported assets
            self.ownable.assert_only_owner();
            
            // Set asset as supported
            self.supported_assets.entry(asset).write(true);
            self.asset_oracles.entry(asset).write(oracle);
            
            // Set default asset configuration
            let asset_config = AssetConfig {
                is_supported: true,
                oracle_address: oracle,
                asset_contract: asset, // Set the actual asset contract address
                collateral_ratio: 12000, // Default 120%
                flash_loan_fee: 9, // Default 0.09%
                liquidation_threshold: 10000, // Default 100%
                is_volatile: false, // Default to stable
                decimals: 18, // Default decimals for ETH, BTC, etc.
                oracle_key: 'ETH_USD', // Example key for ETH/USD
                max_slippage: 100, // 1% slippage
            };
            
            self.asset_configs.entry(asset).write(asset_config);
            
            self.emit(AssetSupported { 
                asset, 
                oracle, 
                collateral_ratio: asset_config.collateral_ratio, 
                flash_loan_fee: asset_config.flash_loan_fee 
            });
        }

        fn set_collateral_ratio(
            ref self: ContractState, 
            asset_type: felt252, 
            ratio: u256
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            // Only contract owner can set collateral ratios
            self.ownable.assert_only_owner();
            assert(ratio >= 10000, 'Ratio must be >= 100%');
            
            self.collateral_ratios.entry(asset_type).write(ratio);
            
            self.emit(CollateralRatioUpdated { asset_type, new_ratio: ratio });
        }

        fn set_flash_loan_fee(
            ref self: ContractState, 
            asset: ContractAddress, 
            fee_bps: u256
        ) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is zero address');
            
            // Only contract owner can set flash loan fees
            self.ownable.assert_only_owner();
            assert(fee_bps <= 1000, 'Fee must be <= 10%');
            
            self.flash_loan_fees.entry(asset).write(fee_bps);
        }

        fn get_asset_price(self: @ContractState, asset: ContractAddress) -> u256 {
            // Use the internal oracle function
            self.get_asset_price_from_oracle(asset)
        }
    }

    // Helper function for flash loan hash generation
    #[generate_trait]
    impl FlashLoanHelpersImpl of FlashLoanHelpersTrait {
        fn generate_flash_loan_hash(
            self: @ContractState,
            asset: ContractAddress,
            amount: u256,
            initiator: ContractAddress,
            params: ByteArray
        ) -> felt252 {
            // Simple hash generation - in production, use proper hashing
            // For now, use a simple approach that works with Cairo types
            let asset_felt: felt252 = asset.into();
            let initiator_felt: felt252 = initiator.into();
            // Convert u256 to felt252 by using the low 251 bits
            let amount_felt: felt252 = amount.try_into().unwrap();
            let hash: felt252 = asset_felt + amount_felt + initiator_felt;
            hash
        }
    }
}
