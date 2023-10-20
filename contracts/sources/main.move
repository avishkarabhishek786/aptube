module addr::Invest {

    use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};
    use std::string;
    use std::string::String;
    use std::option;
    use std::signer;
    use aptos_framework::event;
    use aptos_framework::account;
    use aptos_std::table::{Self, Table}; 

    struct ListedContents has key {
        contents: Table<u64, Content>,
        set_content_event: event::EventHandle<Content>,
        content_counter: u64
    } 

    struct Content has store, drop, copy {
        content_id: u64,
        address:address,
        content_uri: String,
        subscription_price: u64,
    }

      // user Subscription time
    struct usersDuration has store {
        start_at: u64,
        duration: u64,
    }

    // investor 
    struct investorsLockingPeriod has store {
        locking_start: u64,
        locking_duration: u64,
    }
 
    
    // Creator 
    struct productDetails has store, drop {
        content_id: u64,
        creator_address: address,
        total_revenue: u64,   // revenue earned by subscription till now
        remaining_locktime: investorsLockingPeriod, // remaining period after which investor can pull back
        total_fundraised: u64, // investors invested money till now     
        required_capital: u64 // fixed amount to invest    
    }

    // user 
    struct PayToSeeContent has store, key  {
        user_address: address,
        content_id: u64,
        paid_time: usersDuration,
        paid_Amount: u64
        subscription_endTime: u64
    }
    
       
}