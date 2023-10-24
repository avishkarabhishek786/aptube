module admin::Invest {

    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    use std::string;
    use std::string::String;
    use std::option;
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::account;
    use aptos_std::table::{Self, Table};
    use 0x1::aptos_coin::AptosCoin; 
    use 0x1::aptos_account;
    use 0x1::aptos_coin;
    //use std::simple_map::{Self, SimpleMap};

    const E_CALLER_NOT_OWNER: u64 = 401; 
    const E_MODULE_NOT_INITIALIZED: u64 = 402;
    const E_MODULE_ALREADY_INITIALIZED: u64 = 403;
    const E_INSUFFICIENT_BALANCE: u64 = 404;

    struct ListedProject has key {
        projects: Table<u64, Project>,
        set_project_event: event::EventHandle<Project>,
        projects_counter: u64
    } 

    struct Project has store, drop, copy {
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
    struct InvestorsLockingPeriod has store, drop, key {
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

    public entry fun initialize(account: &signer) {

        // get address of caller
        let addr = signer::address_of(account);
        
        // assert caller is owner
        only_owner(addr);

        assert_is_uninitialized(addr);

        let project_list = ListedProject {
            projects: table::new(),
            set_project_event: account::new_event_handle<Project>(account),
            projects_counter: 0
        };

        move_to(account, project_list);
    }

    public entry fun list_project(account: &signer, project_detail:Project) acquires ListedProject {

        // get address of caller
        let caller = signer::address_of(account);
        
        // assert caller is owner
        only_owner(caller);

        assert_is_initialized(caller);

        let project_list = borrow_global_mut<ListedProject>(caller);

        let counter = project_list.projects_counter + 1;

        let new_project = Project {
            id: counter,
            owner:project_detail.owner,
            link: project_detail.link,
            subscription_price: project_detail.subscription_price,
            total_revenue: new_totalrevenue, 
            remaining_locktime: project_detail.remaining_locktime, 
            total_fundraised: project_detail.total_fundraised, 
            required_capital: project_detail.required_capital,  
            is_paid: project_detail.is_paid
        };

        table::upsert(&mut project_list.projects, counter, new_project);

        project_list.projects_counter = counter;

        event::emit_event<Project>(
          &mut borrow_global_mut<ListedProject>(caller).set_project_event,
          new_project,
        );

    }

    public entry fun SubscribeVideo(account: &signer, to_address: address, project_detail:Project, amount:u64) acquires ListedProject {
        let b_addr = signer::address_of(account);
        let balance = my_addrx::BasicTokens::balance_of(b_addr);
        assert!(balance >= 10, E_INSUFFICIENT_BALANCE);

        let product_List = borrow_global_mut<ListedProject>(caller);
        let new_totalrevenue =  product_List.total_revenue + 10;
        let paid_status = product_List.is_paid=true;
        let new_ProjectUpdate =  Project{
            id: project_detail.id,
            owner:project_detail.owner,
            link: project_detail.link,
            subscription_price: project_detail.subscription_price,
            total_revenue: new_totalrevenue, 
            remaining_locktime: project_detail.remaining_locktime, 
            total_fundraised: project_detail.total_fundraised, 
            required_capital: project_detail.required_capital,   
            is_paid: paid_status
        };
        
        table::upsert(&mut  project_list.projects, new_totalrevenue, paid_status, new_ProjectUpdate); //need clarity

        aptos_account::transfer(from,to_address,6);
        aptos_account::transfer(from,to_address,4); //needs modification create ResourceAccount

        let b_store = borrow_global_mut<ListedProject>(to_address);
        vector::push_back(&mut b_store.creator_address, addr);
        b_store.total_revenue = b_store.total_revenue + amount;
    }

}

module admin::BasicTokens{
    use std::error;
    use std::signer;

    /// Error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;
    const EALREADY_INITIALIZED: u64 = 3;
    const EEQUAL_ADDR: u64 = 4;

    struct Coin has store,drop {
        value: u64
    }

    struct Balance has key {
        coin: Coin
    }

    public fun createCoin(v:u64): Coin
    {
        let coin = Coin {
            value:v
        };
        return coin
    }


    public fun publish_balance(account: &signer) {
        let empty_coin = Coin { value: 0 };
        assert!(!exists<Balance>(signer::address_of(account)), error::already_exists(EALREADY_HAS_BALANCE));
        move_to(account, Balance { coin:  empty_coin });
    }

    public fun mint<CoinType: drop>(mint_addr: address, amount: u64) acquires Balance {
        deposit(mint_addr, Coin{ value: amount });
    }

    public fun burn(burn_addr: address, amount: u64) acquires Balance {
        let Coin { value: _ } = withdraw(burn_addr, amount);
    }

    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).coin.value
    }


    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(from_addr != to, EEQUAL_ADDR);
        let check = withdraw(from_addr, amount);
        deposit(to, check);
    }

    public fun withdraw(addr: address, amount: u64) : Coin acquires Balance {
        let balance = balance_of(addr);
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    public fun deposit(addr: address, check: Coin) acquires Balance{
        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }

}