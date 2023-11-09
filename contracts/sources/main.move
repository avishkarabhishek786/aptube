module admin::Invest {

    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    //use std::string;
    use std::string::String;
    //use std::option;
    use std::signer;
    use std::timestamp;
    use aptos_framework::event;
    use aptos_framework::account;
    use aptos_framework::resource_account;
    use aptos_std::table::{Self, Table};
    use 0x1::aptos_coin::AptosCoin; 
    use 0x1::aptos_account;
    //use 0x1::aptos_coin;
    use std::simple_map::{Self, SimpleMap};

    const E_CALLER_NOT_OWNER: u64 = 401; 
    const E_MODULE_NOT_INITIALIZED: u64 = 402;
    const E_MODULE_ALREADY_INITIALIZED: u64 = 403;
    const E_INSUFFICIENT_BALANCE: u64 = 404;
    const E_PROJECT_DOESNT_EXIST:u64 = 405;
    const E_ALREADY_SUBSCRIBED:u64 = 406;
    const E_BLOCKED:u64 = 407;
    const E_INVESTMENT_PERIOD_ACTIVE:u64 = 408;
    const E_INVESTMENT_PERIOD_OVER:u64 = 409;
    const E_LOCKIN_INVAID:u64 = 410;
    const E_NOT_WITHDRAWAL_PERIOD:u64 = 411;
    const E_INVALID_INVESTMENT_TIME:u64 = 412;
    const E_INVALID_REVENUE_TIME:u64 = 413;
    const E_INVALID_WITHDRAWAL_TIME:u64 = 414;
    const E_NOT_INVESTOR:u64 = 415;
    const E_INVALID_WITHDRAWAL_AMOUNT:u64 = 416;
    const E_ALREADY_WITHDRAWN:u64 = 417;
    const E_PROJECT_NOT_LIVE:u64 = 418;
    const DEFAULT_APY:u64 = 1000;//10% APY per year

    struct ListedProject has key {
        projects: Table<u64, Project>,
        signer_cap: account::SignerCapability,
        set_project_event: event::EventHandle<Project>,
        projects_counter: u64
    } 

    struct Project has store, drop {
        id: u64,
        owner:address,
        link: String,
        subscription_price: u64,
        total_revenue: u64,   // revenue earned by subscription till now
        investment_locktime: u64, // period in which investment can be made into a project ~ 15 days
        revenue_locktime: u64, // period upto which revenue will be locked and cannot be withdrawn ~ 6 months after project is live 
        withdrawal_locktime: u64, // period when investors can withdraw their earnings ~ 15 days
        total_fundraised: u64, // investors invested money till now     
        capital_required: u64, // fixed amount to invest   
        is_paid: bool,
        is_blocked: bool,
        investors: SimpleMap<address, Investor>;
    }

    // investor 
    struct Investor has store, drop {
        invested_amount: u64,
        withdrawn: bool,
    }

    public fun only_owner(addr:address) {
        assert!(addr==@admin, E_CALLER_NOT_OWNER);
    }

    public fun assert_is_initialized(store_addr:address) {
        assert!(exists<ListedProject>(store_addr), E_MODULE_NOT_INITIALIZED);
    }

    public fun assert_is_uninitialized(store_addr:address) {
        assert!(!exists<ListedProject>(store_addr), E_MODULE_ALREADY_INITIALIZED);
    }

    fun assert_in_investment_locktime(t:u64) {
        let current_time = timestamp::now_seconds();
        assert!(t > current_time, E_INVESTMENT_PERIOD_ACTIVE);
    } 

    // fun assert_not_in_investment_lockin_period(t:u64) {
    //     let current_time = timestamp::now_seconds();
    //     assert!(t > current_time, E_INVESTMENT_PERIOD_OVER);
    // }  

    fun assert_project_is_live(t:u64) {
        let current_time = timestamp::now_seconds();
        assert!(current_time > t, E_PROJECT_NOT_LIVE); // Current time has passed investment period
    }

    fun assert_in_withdrawal_locktime(withdraw_time:u64, revenue_lock_time:u64) {
        let current_time = timestamp::now_seconds();
        assert!((current_time < withdraw_time) && (current_time > revenue_lock_time), E_NOT_WITHDRAWAL_PERIOD);
    } 

    public entry fun initialize(administrator: &signer) {

        // get address of caller
        let owner = signer::address_of(administrator);
        
        // assert caller is owner
        only_owner(owner);

        assert_is_uninitialized(owner);

        // create the resource account that we'll use to create tokens
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(administrator, owner);
        //let resource_signer = account::create_signer_with_capability(&resource_signer_cap);
        //let resource_account_address = signer::address_of(&resource_signer);

        let project_list = ListedProject {
            projects: table::new(),
            signer_cap: resource_signer_cap,
            set_project_event: account::new_event_handle<Project>(administrator),
            projects_counter: 0
        };

        move_to(administrator, project_list);
    }

    public entry fun list_project(administrator: &signer, project_detail:Project) acquires ListedProject {

        // get address of caller
        let owner = signer::address_of(administrator);
        
        // assert caller is owner
        only_owner(owner);

        assert_is_initialized(owner);

        let listed_projects_ref = borrow_global_mut<ListedProject>(owner);

        //assert!(table::contains(&project_list.projects, project_id), E_PROJECT_DOESNT_EXIST);

        //let projects_list =  &mut listed_projects_ref.projects;
        //let project_ref = table::borrow_mut(&mut listed_projects_ref.projects, project_id);

        //let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

        //let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

        let counter = listed_projects_ref.projects_counter + 1;

        let current_time = timestamp::now_seconds();
        assert!(project_detail.investment_locktime > current_time, E_INVALID_INVESTMENT_TIME);
        assert!(project_detail.revenue_locktime > project_detail.investment_locktime, E_INVALID_REVENUE_TIME);
        assert!(project_detail.withdrawal_locktime > project_detail.revenue_locktime, E_INVALID_WITHDRAWAL_TIME);
        
        let new_project = Project {
            id: counter,
            owner:project_detail.owner,
            link: project_detail.link,
            subscription_price: project_detail.subscription_price,
            total_revenue: 0, 
            investment_locktime: project_detail.investment_locktime, 
            revenue_locktime: project_detail.investment_locktime, 
            withdrawal_locktime: project_detail.investment_locktime, 
            total_fundraised: 0, 
            capital_required: project_detail.capital_required,  
            is_paid: project_detail.is_paid,
            is_blocked: false,
            investors: simple_map::create(),
        };

        table::upsert(&mut listed_projects_ref.projects, counter, new_project);

        listed_projects_ref.projects_counter = counter;

        event::emit_event<Project>(
          &mut borrow_global_mut<ListedProject>(owner).set_project_event,
          new_project,
        );

    }

    public entry fun subscribe_project(subscriber: &signer, project_id: u64, amount:u64) acquires ListedProject {
        
        assert_is_initialized(@admin);
        
        let subscriber_addr = signer::address_of(subscriber);
        let caller_acc_balance:u64 = coin::balance<AptosCoin>(subscriber_addr);
        assert!(caller_acc_balance >= amount, E_INSUFFICIENT_BALANCE);

        let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

        assert!(table::contains(&listed_projects_ref.projects, project_id), E_PROJECT_DOESNT_EXIST);

        let projects_list =  &mut listed_projects_ref.projects;

        let project_ref = table::borrow_mut(&mut listed_projects_ref.projects, project_id);

        assert!(project_ref.is_blocked==false, E_BLOCKED);

        assert_project_is_live(project_ref.investment_locktime); // assert investment period is over

        let current_time = timestamp::now_seconds();

        // If withdrawal time is over all the revenue will go to the platform else in the resource account
        if(current_time>project_ref.withdrawal_locktime) {

            aptos_account::transfer(subscriber, @admin, amount);

        } else {
            let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

            let resource_account_address = signer::address_of(&resource_signer);

            // Payment for subscription. Payment collects into resource account
            aptos_account::transfer(subscriber, resource_account_address, amount);
        }

        // Update subscription data for the subscriber

        assert!(project_ref.is_paid==false, E_ALREADY_SUBSCRIBED);
        project_ref.total_revenue + amount;
        project_ref.is_paid=true;
    }

    public entry fun invest_in_project(investor: &signer, project_id: u64, amount:u64) acquires ListedProject {
        assert_is_initialized(@admin);

        let investor_addr = signer::address_of(investor);
        let caller_acc_balance:u64 = coin::balance<AptosCoin>(investor_addr);

        let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

        assert!(table::contains(&listed_projects_ref.projects, project_id), E_PROJECT_DOESNT_EXIST);
        //let projects_list =  &mut listed_projects_ref.projects;
        
        let project_ref = table::borrow_mut(&mut listed_projects_ref.projects, project_id);

        assert_in_investment_locktime(project_ref.investment_locktime);

        assert!(caller_acc_balance >= project_ref.capital_required, E_INSUFFICIENT_BALANCE);

        let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

        let resource_account_address = signer::address_of(&resource_signer);

        aptos_account::transfer(investor, resource_account_address, amount);
        project_ref.total_fundraised + amount;   
        
        if(simple_map::contains_key(&project_ref.investors, investor_addr)) {
           let investor_total_investment_in_project_ref = simple_map::borrow_mut(&mut project_ref.investors, investor_addr);
           investor_total_investment_in_project_ref.invested_amount + amount;
        } else {

            let investot_struct = Investor {
                address: investor_addr,
                invested_amount: amount,
                withdrawn: false,
            };

            simple_map::add(&mut project_ref.investors, investor_addr, investot_struct);

        } 
        
        
    }

    public entry fun withdraw_invested_amount(caller: &signer, project_id: u64) acquires ListedProject {
        
        assert_is_initialized(@admin);

        let investor_addr = signer::address_of(caller);
        
        let project_ref = table::borrow_mut(&mut listed_projects_ref.projects, project_id);
        
        // assert is investor
        assert!(simple_map::contains_key(&project_ref.investors, investor_addr), E_NOT_INVESTOR);

        // assert in withdrawal period 
        assert_in_withdrawal_locktime(project_ref.withdrawal_locktime, project_ref.revenue_locktime);

        let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

        let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

        let resource_account_address = signer::address_of(&resource_signer);

        // get balanceOf resource_account_address. that will be total revenue
        let resource_account_address_balance = coin::balance<AptosCoin>(resource_account_address);

        // get investors investment amount
        let investor_ref = simple_map::borrow_mut(&mut project_ref.investors, investor_addr);
        assert!(investor_ref.withdrawn==false, E_ALREADY_WITHDRAWN);

        let investor_investment = investor_ref.invested_amount;   

        // get total investment
        let total_investment_raised = project_ref.total_fundraised;

        // get total investment total_revenue
        let total_revenue = project_ref.total_revenue;

        // calculate his wthdrawal amount and withdraw
        let withdrawal_amount = (investor_investment * total_revenue) / total_investment_raised;

        assert!(withdrawal_amount < resource_account_address_balance, E_INVALID_WITHDRAWAL_AMOUNT);
        
        // transfer amount to investor
        aptos_account::transfer(resource_account_address, investor_addr, withdrawal_amount);

        investor_ref.withdrawn = true;
        investor_ref.invested_amount = 0;
    }

    // public entry fun platform_revenue_withdrawal(caller: &signer, withdrawal_amount: u64) acquires ListedProject {

    //     // get address of caller
    //     let owner = signer::address_of(administrator);
        
    //     // assert caller is owner
    //     only_owner(owner);

    //     assert_is_initialized(owner);

    //     let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

    //     let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

    //     let resource_account_address = signer::address_of(&resource_signer);

    //     aptos_account::transfer(resource_account_address, owner, withdrawal_amount);


    // }


}
