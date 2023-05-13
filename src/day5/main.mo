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

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;

  let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

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
          Team = profile.Team;
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
    return #err(#UnexpectedError("not implemented"));
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 4 - END
};