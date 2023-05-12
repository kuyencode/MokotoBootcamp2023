import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

var ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);

let studentCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor{
  getAllStudentsPrincipal : shared query () -> async [Principal];
};

actor class MotoCoin() {

  let mCoin = {
  name : Text = "MotoCoin";
  symbol : Text = "MOC";
  supply : Nat = 0;
  };

  public type Account = Account.Account;
  public type Subaccount = Account.Subaccount;

  // Returns the name of the token
  public query func name() : async Text {
    return mCoin.name;
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return mCoin.symbol;
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    return mCoin.supply;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {

    switch(ledger.get(account)){
      case (null){
        return 0;
      };
      case(?balance){
        return balance; 
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let fromAmount = Option.get(ledger.get(from), 0);
    let toAmount = Option.get(ledger.get(to), 0);

    if (fromAmount < amount){
      return #err("Not enough to transfer");
    };
    return #ok;
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    let getStudent = await studentCanister.getAllStudentsPrincipal();
    
    for (students in getStudent.vals()){
      var giveCoin = {
        name = "MotoCoin";
        symbol = "MOC";
        supply = 100;
      };
    };
    return #ok;
  };
};