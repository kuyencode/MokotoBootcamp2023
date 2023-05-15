import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import IC "Ic";
import Type "Types";
import Iter "mo:base/Iter";

actor class Verifier() {

  public type CanisterId = IC.CanisterId;
  public type CanisterSettings = IC.CanisterSettings;
  public type ManagementCanister = IC.ManagementCanisterInterface;

  type StudentProfile = Type.StudentProfile;
  let studentProfileStore : HashMap.HashMap<Principal, StudentProfile>(4, Principal.equal, Principal.hash);
  stable var stableStudentProfile : [(Principal, StudentProfile)] = [];
  

//Check if the Student exist.
  private func _comfirmProfile( p : Principal) : Bool{
    var profile = studentProfileStore.get(p);
    switch (profile){
      case (null){
        return false;
      };
      case(profile){
        return true;
      };
    };
  };



  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    studentProfileStore.put(caller, profile);
    return #ok();
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let profile = studentProfileStore.get(p);
    switch(profile){
      case(null){
        return #err ("invalid");
      };
      case(?profile){
        return #ok(profile);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch(_comfirmProfile(caller)){
      case(false){
        return #err("You are not a student");
      };
      case(true){
        let newStudentProfile = {
          name = profile.name;
          team = profile.team;
          graduate = false;
        };
        return #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let student = studentProfileStore.remove(caller);
    switch(student){
      case(null){
        return #err("not implemented");
      };
      case(student){
        return #ok();
      }
    };
    
  };


  system func preupgrade() {
	  stableStudentProfile := Iter.toArray(studentProfileStore.entries());
	};

	system func postupgrade() {
		stableStudentProfile := [];
	};

  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {

    let calculator : calculatorInterface = actor(Principal.toText(canisterId));
    
    try {
      let test1 = await calculator.reset();
      if (test1 != 0) {
          return (#err(#UnexpectedValue("Expected 0, got " # Int.toText(test1))));
      };
      let test2 = await calculator.add(1);
        if (test2 != 1 ) {
          return (#err(#UnexpectedValue("Expected 1, got " # Int.toText(test2))));
      };
      let test3 = await calculator.sub(1);
      if (test3 != -1 ) {
          return (#err(#UnexpectedValue("Expected 0, got " # Int.toText(test2))));
      };
        return #ok();
    } catch (e){
        return (#err(#UnexpectedError("Something went wrong with the calculator canister" # Error.message(e))));
    };


    };

  // STEP - 2 END

  // STEP 3 - BEGIN
      //PRIVATE FUNCS
    private func parseControllerHack(errorMessage : Text) : [Principal] {
        let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);
        while (i < words.size()) {
        controllers.add(Principal.fromText(words[i]));
        i += 1;
        };
        Buffer.toArray<Principal>(controllers);
    };

    private func doVerifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
         let managementCanister = actor("aaaaa-aa") : actor {
            canister_status : ({ canister_id : CanisterId }) -> async ({
                status : { #running; #stopping; #stopped };
                settings: CanisterSettings;
                module_hash: ?Blob;
                memory_size: Nat;
                cycles: Nat;
                idle_cycles_burned_per_day: Nat;
            });
        };

        //hacky-hack
        try { 
            ignore await managementCanister.canister_status({ canister_id = canisterId });
        } catch (e) {
            let controllers : [Principal] = parseControllerHack(Error.message(e));
            if (null == Array.find<Principal>(controllers, func p = p == principalId)) return false;
        };
        return true;
    };

  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
    public shared func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
      await doVerifyOwnership(canisterId, p);
  };


  // STEP 3 - END
    private func doTest(canisterId : Principal) : async TestResult {
        let calculator = actor(Principal.toText(canisterId)) : actor {
            add : shared (n : Int) -> async Int;
            sub : shared (n : Nat) -> async Int;
            reset : shared () -> async Int;
        };

        try { let addTest = await calculator.add(2) } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do add func"));
        };
        try { let subTest = await calculator.sub(1) } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do reset func"));
        };
        try { let resetTest = await calculator.reset() } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do reset func"));
        };

        let resetTest = await calculator.reset();
        if (resetTest != 0) return #err(#UnexpectedValue("Value Error: reset func should give 0"));
        let subTest = await calculator.sub(5);
        if (subTest != -5) return #err(#UnexpectedValue("Value Error: sub func gives wrong value"));
        let addTest = await calculator.add(8);
        if (addTest != 3) return #err(#UnexpectedValue("Value Error: add func gives wrong value"));
        //another reset test just to be sure
        let resetTest2 = await calculator.reset();
        if (resetTest != 0) return #err(#UnexpectedValue("Value Error: reset func should give 0"));

        #ok()
    };

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let true = await doVerifyOwnership(canisterId, p) else return #err "This is not your work!";
    let res : TestResult = await doTest(canisterId);

    switch(res) {
      case (#ok) {
        let ?studentProfile = studentProfileStore.get(p) else return #err "profile not found, verifyWork";
        let newStudentProfile = {
          name = studentProfile.name;
          team = studentProfile.team;
          graduate = true;
        };
        studentProfileStore.put(p, newStudentProfile);
        return #ok;
      };
      case (#err x) {
        switch (x) {
          case (#UnexpectedError msg) {return #err msg};
          case (#UnexpectedValue msg) {return #err msg};
        };
      };
    };
  };
};
  // STEP 4 - END