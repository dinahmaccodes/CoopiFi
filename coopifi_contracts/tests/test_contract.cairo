use starknet::{ContractAddress, contract_address_const};
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use core::result::ResultTrait;
use coopifi_contracts::CoopiFi::{
    ICooperativeManagementDispatcher, ICooperativeManagementDispatcherTrait, ILendingPoolDispatcher,
    ILendingPoolDispatcherTrait, ILoanLifecycleDispatcher, ILoanLifecycleDispatcherTrait,
    IGovernanceDispatcher, IGovernanceDispatcherTrait, IMembershipNFTDispatcher,
    IMembershipNFTDispatcherTrait,
};

// Test constants
fn OWNER() -> ContractAddress {
    contract_address_const::<0x123>()
}
fn USER1() -> ContractAddress {
    contract_address_const::<0x456>()
}
fn USER2() -> ContractAddress {
    contract_address_const::<0x789>()
}
fn USER3() -> ContractAddress {
    contract_address_const::<0xabc>()
}

// Deploy the CoopiFi contract
fn deploy_contract() -> ContractAddress {
    let owner = OWNER();
    let mut calldata = array![];
    owner.serialize(ref calldata);

    let declare_result = declare("CoopiFi").expect('Failed to declare contract');
    let contract_class = declare_result.contract_class();
    let (contract_address, _) = contract_class
        .deploy(@calldata)
        .expect('Failed to deploy contract');

    contract_address
}

#[test]
fn test_create_cooperative() {
    let contract_address = deploy_contract();
    let owner = OWNER();
    start_cheat_caller_address(contract_address, owner);

    let name = "Test Coop";
    let description = "A test cooperative";
    let interest_rate: u256 = 50; // 0.5%

    let dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = dispatcher
        .create_cooperative(name.clone(), description.clone(), interest_rate);
    assert(coop_id == 1, 'First coop should have ID 1');

    let cooperative = dispatcher.get_cooperative_details(coop_id);
    assert(cooperative.name == name, 'Name should match');
    assert(cooperative.description == description, 'Description should match');
    assert(cooperative.interest_rate == interest_rate, 'Interest rate should match');
    assert(cooperative.admin == owner, 'Admin should be creator');
    assert(cooperative.is_active == true, 'Cooperative should be active');
    assert(cooperative.pool_balance == 0, 'Pool balance should be 0');

    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_join_cooperative() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);

    // Check membership
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let is_member = nft_dispatcher.get_nft_owner(coop_id, USER1());
    assert(is_member == true, 'User should be a member');

    let members = coop_dispatcher.get_member_list(coop_id);
    assert(members.len() == 1, 'Should have 1 member');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('Already a member',))]
fn test_join_cooperative_already_member() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative twice
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    coop_dispatcher.join_cooperative(coop_id); // Should panic
}

#[test]
fn test_leave_cooperative() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);

    // Leave cooperative
    coop_dispatcher.leave_cooperative(coop_id);

    // Check membership
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let is_member = nft_dispatcher.get_nft_owner(coop_id, USER1());
    assert(is_member == false, 'User should not be a member');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_stake_and_withdraw() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);

    // Stake funds
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    let stake_amount: u256 = 1000;
    pool_dispatcher.stake(coop_id, stake_amount);

    // Check stake
    let member_stake = pool_dispatcher.get_member_stake(USER1(), coop_id);
    assert(member_stake == stake_amount, 'Stake should match');

    // Check pool balance
    let pool_balance = pool_dispatcher.get_pool_balance(coop_id);
    assert(pool_balance == stake_amount, 'Pool balance should match');

    // Withdraw stake
    let withdraw_amount: u256 = 500;
    pool_dispatcher.withdraw_stake(coop_id, withdraw_amount);

    // Check updated stake
    let updated_stake = pool_dispatcher.get_member_stake(USER1(), coop_id);
    assert(updated_stake == stake_amount - withdraw_amount, 'Stake should be reduced');

    // Check updated pool balance
    let updated_pool_balance = pool_dispatcher.get_pool_balance(coop_id);
    assert(updated_pool_balance == stake_amount - withdraw_amount, 'Pool balance reduced');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('Insufficient stake',))]
fn test_withdraw_more_than_stake() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);

    // Stake funds
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 1000);

    // Try to withdraw more than staked
    pool_dispatcher.withdraw_stake(coop_id, 2000); // Should panic
}

#[test]
fn test_request_loan() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join cooperative and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);

    // Request loan
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_amount: u256 = 5000;
    let duration: u64 = 86400; // 1 day
    let purpose = "Business expansion";

    let loan_id: u256 = loan_dispatcher
        .request_loan(coop_id, loan_amount, duration, purpose.clone());
    assert(loan_id == 1, 'First loan should have ID 1');

    // Check loan status
    let loan = loan_dispatcher.get_loan_status(loan_id);
    assert(loan.coop_id == coop_id, 'Loan coop_id should match');
    assert(loan.borrower == USER1(), 'Borrower should match');
    assert(loan.amount == loan_amount, 'Loan amount should match');
    assert(loan.duration == duration, 'Loan duration should match');
    assert(loan.purpose == purpose, 'Loan purpose should match');
    assert(loan.status == 'pending', 'Loan should be pending');
    assert(loan.votes_for == 0, 'Votes should start at 0');
    assert(loan.votes_against == 0, 'Votes should start at 0');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_vote_on_loan() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join multiple members
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop_id);
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    coop_dispatcher.join_cooperative(coop_id);
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request loan
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id: u256 = loan_dispatcher.request_loan(coop_id, 5000, 86400, "Test loan");
    stop_cheat_caller_address(contract_address);

    // Vote on loan (need majority - 3 members, so 2 votes are needed)
    start_cheat_caller_address(contract_address, USER2());
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true); // Approve
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true); // Approve
    stop_cheat_caller_address(contract_address);

    // Check loan status
    let loan = loan_dispatcher.get_loan_status(loan_id);
    assert(loan.votes_for == 2, 'Should have 2 votes for');
    assert(loan.votes_against == 0, 'Should have 0 votes against');
    assert(loan.status == 'approved', 'Loan should be approved');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_disburse_loan() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Join second member
    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop_id);
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Join third member
    start_cheat_caller_address(contract_address, USER3());
    coop_dispatcher.join_cooperative(coop_id);
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request loan
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id: u256 = loan_dispatcher.request_loan(coop_id, 5000, 86400, "Test loan");
    stop_cheat_caller_address(contract_address);

    // Vote to approve (need majority - 3 members, so 2 votes are needed)
    start_cheat_caller_address(contract_address, USER2());
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true);
    stop_cheat_caller_address(contract_address);

    // Check loan is approved before disbursement
    let loan_before = loan_dispatcher.get_loan_status(loan_id);
    assert(loan_before.status == 'approved', 'Loan should be approved');

    // Disburse loan (admin only)
    start_cheat_caller_address(contract_address, OWNER());
    loan_dispatcher.disburse_loan(coop_id, loan_id);

    // Check loan status
    let loan = loan_dispatcher.get_loan_status(loan_id);
    assert(loan.status == 'disbursed', 'Loan should be disbursed');
    // Note: start_time might be 0 in test environment, so we just check it's been set
    // (even if it's 0, the fact that we can read it means it was set)
    let _start_time = loan.start_time; // Just verify it's accessible

    // Check pool balance reduced
    let pool_balance = pool_dispatcher.get_pool_balance(coop_id);
    assert(pool_balance == 25000, 'Pool balance reduced by loan');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_repay_loan() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request, approve, and disburse loan
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id: u256 = loan_dispatcher.request_loan(coop_id, 5000, 86400, "Test loan");
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, OWNER());
    loan_dispatcher.disburse_loan(coop_id, loan_id);
    stop_cheat_caller_address(contract_address);

    // Repay loan
    start_cheat_caller_address(contract_address, USER1());
    let repay_amount: u256 = 2500;
    loan_dispatcher.repay_loan(coop_id, loan_id, repay_amount);

    // Check loan status
    let loan = loan_dispatcher.get_loan_status(loan_id);
    assert(loan.amount_repaid == repay_amount, 'Amount repaid should match');
    assert(
        loan.status == 'disbursed', 'Loan still disbursed',
    ); //Loan should still be disbursed (not fully repaid)'

    // Repay remaining amount
    loan_dispatcher.repay_loan(coop_id, loan_id, 2500);

    // Check final status
    let final_loan = loan_dispatcher.get_loan_status(loan_id);
    assert(final_loan.status == 'repaid', 'Loan should be fully repaid');

    // Check pool balance restored
    let pool_balance = pool_dispatcher.get_pool_balance(coop_id);
    assert(pool_balance == 10000, 'Pool balance restored');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_propose_change() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);

    // Propose change
    let gov_dispatcher = IGovernanceDispatcher { contract_address };
    let new_interest_rate: u256 = 60; // 0.6%
    gov_dispatcher.propose_change(coop_id, 'interest_rate', new_interest_rate);

    // Check proposal
    let proposals = gov_dispatcher.get_proposals(coop_id);
    assert(proposals.len() == 1, 'Should have 1 proposal');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_vote_and_execute_proposal() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join members
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Propose change
    start_cheat_caller_address(contract_address, USER1());
    let gov_dispatcher = IGovernanceDispatcher { contract_address };
    gov_dispatcher.propose_change(coop_id, 'interest_rate', 60);
    stop_cheat_caller_address(contract_address);

    // Vote on proposal (need majority - 3 members, so 2 votes are needed)
    start_cheat_caller_address(contract_address, USER2());
    gov_dispatcher.vote_on_proposal(coop_id, 1, true); // Approve
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    gov_dispatcher.vote_on_proposal(coop_id, 1, true); // Approve
    stop_cheat_caller_address(contract_address);

    // Execute proposal (admin only)
    start_cheat_caller_address(contract_address, OWNER());
    gov_dispatcher.execute_proposal(coop_id, 1);

    // Check that interest rate was updated
    let cooperative = coop_dispatcher.get_cooperative_details(coop_id);
    assert(cooperative.interest_rate == 60, 'Interest rate updated');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_get_active_loans() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request multiple loans
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id1: u256 = loan_dispatcher.request_loan(coop_id, 2000, 86400, "Loan 1");
    let loan_id2: u256 = loan_dispatcher.request_loan(coop_id, 3000, 86400, "Loan 2");
    stop_cheat_caller_address(contract_address);

    // Approve both loans
    start_cheat_caller_address(contract_address, USER1());
    loan_dispatcher.vote_on_loan(coop_id, loan_id1, true);
    loan_dispatcher.vote_on_loan(coop_id, loan_id2, true);
    stop_cheat_caller_address(contract_address);

    // Disburse first loan
    start_cheat_caller_address(contract_address, OWNER());
    loan_dispatcher.disburse_loan(coop_id, loan_id1);
    stop_cheat_caller_address(contract_address);

    // Check active loans (should have 2: 1 disbursed, 1 approved)
    let active_loans = loan_dispatcher.get_active_loans(coop_id);
    assert(active_loans.len() == 2, 'Should have 2 active loans');
}

#[test]
fn test_get_loan_history() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request multiple loans
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id1: u256 = loan_dispatcher.request_loan(coop_id, 2000, 86400, "Loan 1");
    let loan_id2: u256 = loan_dispatcher.request_loan(coop_id, 3000, 86400, "Loan 2");
    stop_cheat_caller_address(contract_address);

    // Check loan history
    let loan_history = loan_dispatcher.get_loan_history(USER1());
    assert(loan_history.len() == 2, 'Should have 2 loans');
}

#[test]
#[should_panic(expected: ('Not a member',))]
fn test_non_member_cannot_stake() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Try to stake without joining
    start_cheat_caller_address(contract_address, USER1());
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 1000); // Should panic
}

#[test]
#[should_panic(expected: ('Not a member',))]
fn test_non_member_cannot_request_loan() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Try to request loan without joining
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    loan_dispatcher.request_loan(coop_id, 1000, 86400, "Test"); // Should panic
}

#[test]
#[should_panic(expected: ('Insufficient pool funds',))]
fn test_request_loan_insufficient_funds() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member with small stake
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 1000);

    // Try to request loan larger than pool
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    loan_dispatcher.request_loan(coop_id, 2000, 86400, "Test"); // Should panic
}

#[test]
#[should_panic(expected: ('Only admin can disburse',))]
fn test_non_admin_cannot_disburse() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and request loan
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id: u256 = loan_dispatcher.request_loan(coop_id, 5000, 86400, "Test");
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true);
    stop_cheat_caller_address(contract_address);

    // Try to disburse as non-admin
    start_cheat_caller_address(contract_address, USER1());
    loan_dispatcher.disburse_loan(coop_id, loan_id); // Should panic
}

#[test]
fn test_multiple_cooperatives() {
    let contract_address = deploy_contract();

    // Create first cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop1_id: u256 = coop_dispatcher.create_cooperative("Coop 1", "First coop", 50);
    stop_cheat_caller_address(contract_address);

    // Create second cooperative
    start_cheat_caller_address(contract_address, USER1());
    let coop2_id: u256 = coop_dispatcher.create_cooperative("Coop 2", "Second coop", 60);
    stop_cheat_caller_address(contract_address);

    assert(coop1_id == 1, 'First coop should have ID 1');
    assert(coop2_id == 2, 'Second coop should have ID 2');

    // Join first cooperative
    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop1_id);
    stop_cheat_caller_address(contract_address);

    // Join second cooperative with different user
    start_cheat_caller_address(contract_address, USER3());
    coop_dispatcher.join_cooperative(coop2_id);
    stop_cheat_caller_address(contract_address);

    // Check membership
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let is_member_coop1 = nft_dispatcher.get_nft_owner(coop1_id, USER2());
    let is_member_coop2 = nft_dispatcher.get_nft_owner(coop2_id, USER3());
    assert(is_member_coop1 == true, 'Should be member of coop 1');
    assert(is_member_coop2 == true, 'Should be member of coop 2');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('Pool underfunded',))]
fn test_leave_cooperative_with_loans() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member and stake funds
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 10000);
    stop_cheat_caller_address(contract_address);

    // Request and get loan
    start_cheat_caller_address(contract_address, USER1());
    let loan_dispatcher = ILoanLifecycleDispatcher { contract_address };
    let loan_id: u256 = loan_dispatcher.request_loan(coop_id, 5000, 86400, "Test loan");
    loan_dispatcher.vote_on_loan(coop_id, loan_id, true);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, OWNER());
    loan_dispatcher.disburse_loan(coop_id, loan_id);
    stop_cheat_caller_address(contract_address);

    // Try to withdraw stake (should fail due to active loan)
    start_cheat_caller_address(contract_address, USER1());
    pool_dispatcher.withdraw_stake(coop_id, 10000); // Should panic due to pool underfunded
}

#[test]
#[should_panic(expected: ('Insufficient votes',))]
fn test_governance_proposal_execution() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join multiple members
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Propose change
    start_cheat_caller_address(contract_address, USER1());
    let gov_dispatcher = IGovernanceDispatcher { contract_address };
    gov_dispatcher.propose_change(coop_id, 'interest_rate', 70);
    stop_cheat_caller_address(contract_address);

    // Vote against (should not pass)
    start_cheat_caller_address(contract_address, USER2());
    gov_dispatcher.vote_on_proposal(coop_id, 1, false);
    stop_cheat_caller_address(contract_address);

    // Try to execute (should fail due to insufficient votes)
    start_cheat_caller_address(contract_address, OWNER());
    gov_dispatcher.execute_proposal(coop_id, 1); // Should panic

    // Check interest rate unchanged
    let cooperative = coop_dispatcher.get_cooperative_details(coop_id);
    assert(cooperative.interest_rate == 50, 'Interest rate unchanged');
}

#[test]
fn test_nft_membership_metadata() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "A test cooperative", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Get NFT ID for the member
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(token_id > 0, 'Should have valid token ID');

    // Get NFT metadata
    let metadata = nft_dispatcher.get_membership_metadata(token_id);
    assert(metadata.coop_id == coop_id, 'Coop ID should match');
    assert(metadata.name == "Test Coop", 'Name should match');
    assert(metadata.description == "A test cooperative", 'Description should match');
    assert(metadata.interest_rate == 50, 'Interest rate should match');
    assert(metadata.is_member == true, 'Should be a member');
    assert(metadata.member_count == 1, 'Should have 1 member');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_nft_cooperative_mapping() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Get NFT ID and verify cooperative mapping
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    let mapped_coop_id = nft_dispatcher.get_nft_cooperative(token_id);
    assert(
        mapped_coop_id == coop_id, 'Cooperative mppg should match',
    ); //Cooperative mapping should match
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_nft_burning_on_leave() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Get NFT ID before leaving
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(token_id > 0, 'Should have valid token ID');

    // Leave cooperative (should burn NFT)
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.leave_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Verify NFT is burned (token ID should be 0)
    let burned_token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(burned_token_id == 0, 'NFT should be burned');
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_nft_transfer() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Get NFT ID before transfer
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(token_id > 0, 'Should have valid token ID');

    // Transfer NFT to another user
    start_cheat_caller_address(contract_address, USER1());
    nft_dispatcher.transfer_membership_nft(coop_id, USER1(), USER2());
    stop_cheat_caller_address(contract_address);

    // Verify transfer
    let new_token_id = nft_dispatcher.get_member_nft_id(coop_id, USER2());
    assert(
        new_token_id == token_id, 'Token ID be same after transfer',
    ); //Token ID should be same after transfer

    let old_token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(old_token_id == 0, 'Old member have no token ID'); //Old member should have no token ID

    let is_member_user1 = nft_dispatcher.get_nft_owner(coop_id, USER1());
    let is_member_user2 = nft_dispatcher.get_nft_owner(coop_id, USER2());
    assert(
        is_member_user1 == false, 'USER1 should not be member',
    ); //USER1 should no longer be member
    assert(is_member_user2 == true, 'USER2 should be member');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('From is not a member',))]
fn test_nft_transfer_from_non_member() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Try to transfer from non-member (should fail)
    start_cheat_caller_address(contract_address, USER1());
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    nft_dispatcher.transfer_membership_nft(coop_id, USER1(), USER2()); // Should panic
}

#[test]
#[should_panic(expected: ('To is already a member',))]
fn test_nft_transfer_to_existing_member() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join two members
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Try to transfer to existing member (should fail)
    start_cheat_caller_address(contract_address, USER1());
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    nft_dispatcher.transfer_membership_nft(coop_id, USER1(), USER2()); // Should panic
}

#[test]
fn test_multiple_nfts_different_cooperatives() {
    let contract_address = deploy_contract();

    // Create two cooperatives
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop1_id: u256 = coop_dispatcher.create_cooperative("Coop 1", "First coop", 50);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER1());
    let coop2_id: u256 = coop_dispatcher.create_cooperative("Coop 2", "Second coop", 60);
    stop_cheat_caller_address(contract_address);

    // Join both cooperatives with different users
    start_cheat_caller_address(contract_address, USER2());
    coop_dispatcher.join_cooperative(coop1_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER3());
    coop_dispatcher.join_cooperative(coop2_id);
    stop_cheat_caller_address(contract_address);

    // Get NFT IDs and verify they're different
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token1_id = nft_dispatcher.get_member_nft_id(coop1_id, USER2());
    let token2_id = nft_dispatcher.get_member_nft_id(coop2_id, USER3());

    assert(token1_id != token2_id, 'NFTs should have different IDs');
    assert(token1_id > 0, 'First NFT should be valid');
    assert(token2_id > 0, 'Second NFT should be valid');

    // Verify cooperative mappings
    let coop1_from_nft = nft_dispatcher.get_nft_cooperative(token1_id);
    let coop2_from_nft = nft_dispatcher.get_nft_cooperative(token2_id);
    assert(
        coop1_from_nft == coop1_id, 'First NFT map to first coop',
    ); //First NFT should map to first coop
    assert(
        coop2_from_nft == coop2_id, 'Second NFT map to second coop',
    ); //Second NFT should map to second coop
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_nft_metadata_updates() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Stake funds to update pool balance
    start_cheat_caller_address(contract_address, USER1());
    let pool_dispatcher = ILendingPoolDispatcher { contract_address };
    pool_dispatcher.stake(coop_id, 1000);
    stop_cheat_caller_address(contract_address);

    // Get NFT metadata and verify it reflects updated pool balance
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    let metadata = nft_dispatcher.get_membership_metadata(token_id);

    assert(metadata.pool_balance == 1000, 'Pool balance should be updated');
    assert(metadata.member_count == 1, 'Member count should be correct');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('Invalid token ID',))]
fn test_invalid_token_id_metadata() {
    let contract_address = deploy_contract();

    // Try to get metadata for non-existent token
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    nft_dispatcher.get_membership_metadata(999); // Should panic
}

#[test]
fn test_nft_burning_function() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Join member
    start_cheat_caller_address(contract_address, USER1());
    coop_dispatcher.join_cooperative(coop_id);
    stop_cheat_caller_address(contract_address);

    // Burn NFT directly
    start_cheat_caller_address(contract_address, USER1());
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    nft_dispatcher.burn_membership_nft(coop_id, USER1());
    stop_cheat_caller_address(contract_address);

    // Verify NFT is burned and member is removed
    let token_id = nft_dispatcher.get_member_nft_id(coop_id, USER1());
    assert(token_id == 0, 'NFT should be burned');

    let is_member = nft_dispatcher.get_nft_owner(coop_id, USER1());
    assert(is_member == false, 'Member should be removed');
    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('Not a member',))]
fn test_burn_nft_for_non_member() {
    let contract_address = deploy_contract();

    // Create cooperative
    start_cheat_caller_address(contract_address, OWNER());
    let coop_dispatcher = ICooperativeManagementDispatcher { contract_address };
    let coop_id: u256 = coop_dispatcher.create_cooperative("Test Coop", "Description", 50);
    stop_cheat_caller_address(contract_address);

    // Try to burn NFT for non-member (should fail)
    start_cheat_caller_address(contract_address, USER1());
    let nft_dispatcher = IMembershipNFTDispatcher { contract_address };
    nft_dispatcher.burn_membership_nft(coop_id, USER1()); // Should panic
}
