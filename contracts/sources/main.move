module admin::Invest {

    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    //use std::string;
    use std::string::String;
    //use std::option;
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::account;
    use aptos_framework::resource_account;
    use aptos_std::table::{Self, Table};
    use 0x1::aptos_coin::AptosCoin; 
    use 0x1::aptos_account;
    //use 0x1::aptos_coin;
    //use std::simple_map::{Self, SimpleMap};

    const E_CALLER_NOT_OWNER: u64 = 401; 
    const E_MODULE_NOT_INITIALIZED: u64 = 402;
    const E_MODULE_ALREADY_INITIALIZED: u64 = 403;
    const E_INSUFFICIENT_BALANCE: u64 = 404;
    const E_PROJECT_DOESNT_EXIST:u64 = 405;
    const E_ALREADY_SUBSCRIBED:u64 = 406;

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
        remaining_locktime: InvestorsLockingPeriod, // remaining period after which investor can pull back
        total_fundraised: u64, // investors invested money till now     
        required_capital: u64, // fixed amount to invest   
        is_paid: bool
    }

    // struct productDetails has store, drop {
    //     content_id: u64,
    //     creator_address: address,
    //     total_revenue: u64,   // revenue earned by subscription till now
    //     remaining_locktime: investorsLockingPeriod, // remaining period after which investor can pull back
    //     total_fundraised: u64, // investors invested money till now     
    //     required_capital: u64 // fixed amount to invest    
    // }
    

    // user Subscription time
    struct UsersDuration has store {
        start_at: u64,
        duration: u64,
    }

    // investor 
    struct InvestorsLockingPeriod has store, drop, copy {
        locking_start: u64,
        locking_duration: u64,
    }

    // user 
    struct PayToSeeContent has store, key  {
        user_address: address,
        content_id: u64,
        paid_time: UsersDuration,
        paid_Amount: u64,
        subscription_endTime: u64
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
        
        let new_project = Project {
            id: counter,
            owner:project_detail.owner,
            link: project_detail.link,
            subscription_price: project_detail.subscription_price,
            total_revenue: 0, 
            remaining_locktime: project_detail.remaining_locktime, 
            total_fundraised: project_detail.total_fundraised, 
            required_capital: project_detail.required_capital,  
            is_paid: project_detail.is_paid
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
        assert!(caller_acc_balance >= 10, E_INSUFFICIENT_BALANCE);

        let listed_projects_ref = borrow_global_mut<ListedProject>(@admin);

        let resource_signer = account::create_signer_with_capability(&listed_projects_ref.signer_cap);

        let resource_account_address = signer::address_of(&resource_signer);

        // Payment for subscription. Payment collects into resource account
        aptos_account::transfer(subscriber,resource_account_address, amount);

        // Update subscription data for the subscriber

        assert!(table::contains(&listed_projects_ref.projects, project_id), E_PROJECT_DOESNT_EXIST);

        let projects_list =  &mut listed_projects_ref.projects;
        let project_ref = table::borrow_mut(&mut listed_projects_ref.projects, project_id);
        assert!(project_ref.is_paid==false, E_ALREADY_SUBSCRIBED);
        let new_totalrevenue =  project_ref.total_revenue + 10;
        project_ref.is_paid=true;

    }

}
