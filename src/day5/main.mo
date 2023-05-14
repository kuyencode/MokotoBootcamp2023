//old work

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
import Ic "Ic";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  stable var studentEntries:[(Principal, StudentProfile)] = [];
  let iter = studentEntries.vals();
  let studentProfileStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.fromIter<Principal, StudentProfile>(iter, 0, Principal.equal, Principal.hash);
  

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
    // return Iter.toArray(StudentProfileStore.entries());
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
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
    public shared func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    try{
      let IC0 = actor("aaaaa-aa") : actor {
      canister_status : { canister_id : Principal } -> async {cycles : Nat};
      };

      let h = await IC0.canister_status({canister_id = canisterId});
      return false;
    } catch(err){
       let controllers: [Principal] = parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(err));
      return not ((Array.find<Principal>(controllers, func(id: Principal){id == p})) == null);
    };    
  };

    func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
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


  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let isItTheOwner : Bool = await verifyOwnership(canisterId, p);
    if (isItTheOwner) {
      let canisterTest : Type.TestResult = await test(canisterId);

    switch (canisterTest) {
      case (#ok()) {
        var hasProfile = studentProfileStore.get(p);
      switch (hasProfile) {
        case (?studentProfile) {
          let graduatedProfile = {
            team = studentProfile.team;
            name = studentProfile.name;
            graduate = true;
          };
        studentProfileStore.put(p, graduatedProfile);
        return #ok();
        };
        case (null) {
        return #err("The principal has not a registered profile");
        };
      };
    };
      case (#err(_)) {
      return #err("The canister does not pass the test");
      };
    };
    } else {
    return #err("The caller isn't the owner of the canister");
    };
  };
};
  // STEP 4 - END