module admin::Invest {

    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    use std::string;
    use std::string::String;
    use std::option;
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::account;
    use aptos_std::table::{Self, Table}; 
    //use std::simple_map::{Self, SimpleMap};

    const E_CALLER_NOT_OWNER: u64 = 401; 
    const E_MODULE_NOT_INITIALIZED: u64 = 402;
    const E_MODULE_ALREADY_INITIALIZED: u64 = 403;

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
        is_paid: bool
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
            is_paid: project_detail.is_paid
        };

        table::upsert(&mut project_list.projects, counter, new_project);

        project_list.projects_counter = counter;

        event::emit_event<Project>(
          &mut borrow_global_mut<ListedProject>(caller).set_project_event,
          new_project,
        );

    }
    
}