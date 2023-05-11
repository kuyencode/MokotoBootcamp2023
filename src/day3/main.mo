import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Order "mo:base/Order";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  var messageIdCounter : Nat = 0 ;

  let wall = HashMap.HashMap<Nat, Message>(1, Nat.equal,  func (x) {Text.hash(Nat.toText(x))});

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let id : Nat = messageIdCounter;
    messageIdCounter += 1; 
    let newMessage = {
      content = c;
      vote = 0;
      creator = caller;
    };
    wall.put(id,newMessage);
    return id;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch(wall.get(messageId)) {
        case(null){
            #err("Invalid");
        };
        case(?message){
            #ok message;
        };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let message : ?Message = wall.get(messageId);
    switch(message){
      case(null){
          #err("Invalid");
      };
      case(?currentMessage){
        if(Principal.equal(currentMessage.creator, caller)){
          let updatedMessage : Message = {
          vote = currentMessage.vote;
          content = c;
          creator = currentMessage.creator;
        };
        wall.put(messageId, updatedMessage);
        #ok; 
        }
        else {
          #err("You don't have the rights to update");
        };
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let delMessage : ?Message = wall.get(messageId);
    switch(delMessage){
      case (null){
        return #err("Invalid");
      };
      case(_){
        ignore wall.remove(messageId);
        return #ok();
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let message : ?Message = wall.get(messageId);

    switch(message){
      case(null){
        return #err("Invalid");
      };
      case(?currentMessage){
        let upVoteMessage = {
          content = currentMessage.content;
          vote = currentMessage.vote + 1;
          creator = currentMessage.creator;   
        };
        wall.put(messageId, upVoteMessage);
        return #ok();
      };
    };
   
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let message : ?Message = wall.get(messageId);
    
    switch(message){
      case(null){
        return #err("Invalid");
      };
      case(?currentMessage){
        let downVoteMessage = {
          content = currentMessage.content;
          vote = currentMessage.vote - 1;
          creator = currentMessage.creator;   
        };
        wall.put(messageId, downVoteMessage);
        return #ok();
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let messageBuffer = Buffer.Buffer<Message>(0);
    for (items in wall.vals()){
      messageBuffer.add(items);
    };
    return Buffer.toArray<Message>(messageBuffer);
  };

  private func _compareMessage(m1: Message, m2: Message): Order.Order {
    if (m1.vote == m2.vote){
        return #equal;
      };
      return #greater;
    };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let array : [Message] = Iter.toArray(wall.vals());
    return Array.sort<Message>(array, _compareMessage);
  };
};
