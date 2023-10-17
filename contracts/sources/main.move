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
    
}