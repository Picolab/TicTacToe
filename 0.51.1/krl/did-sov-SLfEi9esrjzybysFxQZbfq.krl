ruleset did-sov-SLfEi9esrjzybysFxQZbfq {
  meta {
    name "TicTacToe"
    description <<
      Implements protocol for Tic Tac Toe over DIDComm
      did:sov:SLfEi9esrjzybysFxQZbfq;spec/tictactoe/1.0
    >>
    use module io.picolabs.wrangler alias wrangler
    use module org.sovrin.agent alias agent
    shares __testing, ui_url, start_message
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "ui_url" }
      ] , "events":
      [
      ]
    }
    piuri = "did:sov:SLfEi9esrjzybysFxQZbfq;spec/tictactoe/1.0"
    tttMoveMap = function(me,moves,comment){
      {
        "@type": piuri + "/move",
        "me": me,
        "moves": moves,
        "comment": comment || "move " + moves[moves.length()-1]
      } // caller to add threading
    }
    tttOutcomeMap = function(winner,comment){
      {
        "@type": piuri + "/outcome",
        "winner": winner,
        "comment": comment || "game over"
      } // caller to add threading
    }
    aux_rid = "org.sovrin.tic_tac_toe"
    ui_url = function(){
      eci = meta:eci;
      <<#{meta:host}/sky/cloud/#{eci}/#{aux_rid}/html.html>>
    }
    start_message = function(me,move){
      cell = move => move.split(":").tail().head() | null;
      comment = <<Let's play tic-tac-toe. I'll be #{me}. >>
        + (cell.isnull() => "Your move." | <<I pick cell #{cell}.>>);
      tttMoveMap(me,move => [move] | [],comment)
        .put("@id",random:uuid())
    }
    possible_opponents = function(conns){
      (conns => conns | agent:connections())
        .values()
        .sort(function(a,b){a{"created"} cmp b{"created"}})
        .reduce(function(m,v){m.put(v{"their_vk"},v{"label"})},{})
    }
    channel_name = "tictactoe"
    tictactoe_policy = {
      "name": "Tic Tac Toe policy",
      "event": {
        "allow": [
          { "domain": "sovrin", "type": "send_basicmessage" },
          { "domain": "http", "type": "post" },
          { "domain": "ttt", "type": "start" },
          { "domain": "ttt", "type": "send_move" },
          { "domain": "ttt", "type": "reset_requested" },
        ]
      },
      "query": {
        "allow": [
          { "rid": meta:rid, "name": "start_message"},
          { "rid": aux_rid, "name": "state" },
          { "rid": aux_rid, "name": "html" },
        ]
      },
    }
  }
//
// identify as agent plug-in
//
  rule identify_as_agent_plug_in {
    select when agent request_for_plug_ins
    pre {
      plugin = {
        "rid": meta:rid,
        "piuri": piuri,
        "name": meta:rulesetName,
        "ui_html_rid": aux_rid,
        "ui_html_name": "html",
        "channel_name": channel_name,
        "channel_id": wrangler:channel(channel_name){"id"} || meta:eci,
      }
    }
    send_directive("spec",plugin)
    fired {
      raise agent event "plugin_reported" attributes plugin
    }
  }
//
// bookkeeping
//
  rule use_auxiliary_ruleset {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      raise wrangler event "install_rulesets_requested"
        attributes {"rid":aux_rid,"proto_rid":meta:rid}
    }
  }
  rule send_possible_opponents {
    select when wrangler ruleset_added where event:attr("rids") >< aux_rid
    fired {
      raise ttt event "possible_opponents_change"
        attributes {"possible_opponents": possible_opponents()}
    }
  }
  rule create_engine_policy {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      the_policy = engine:listPolicies()
        .filter(function(v){v{"name"}==tictactoe_policy{"name"}})
        .head()
    }
    if the_policy.isnull() then
      wrangler:newPolicy(tictactoe_policy)
  }
  rule create_game_channel {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      the_policy = engine:listPolicies()
        .filter(function(v){v{"name"}==tictactoe_policy{"name"}})
        .head()
    }
    if wrangler:channel(channel_name).isnull() then
      wrangler:createChannel(meta:picoId,channel_name,"ui",the_policy{"id"})
  }
  rule update_possible_opponents {
    select when agent connections_changed
    pre {
      conns = event:attr("connections")
    }
    fired {
      raise ttt event "possible_opponents_change"
        attributes {"possible_opponents": possible_opponents(conns)}
    }
  }
//
// handle received protocol message if for me
//
  rule handle_received_protocol_message {
    select when plugin protocol_message_received
      where event:attr("piuri") == piuri
    pre {
      content = event:attr("content")
      event_type = event:attr("event_type")
      their_vk = event:attr("sender_key")
      conn = agent:connections(){their_vk}
    }
    if conn then noop()
    fired {
      ent:opponent := conn{"label"};
      ent:their_vk := conn{"their_vk"};
      ent:my_did := conn{"my_did"};
      raise tictactoe event event_type attributes content
    }
  }
//
// tictactoe/1.0/move
//
  rule handle_initial_move_message {
    select when tictactoe move
      me re#^([XO])$# setting(me)
      where event:attr("@id") && ent:thid.isnull()
    pre {
      moves = event:attr("moves").decode() || []
      initial_move = moves.typeof()=="Array"
                  && moves.length() <= 1
      move = moves.length()==0 => null | moves.head()
    }
    if initial_move then send_directive("initial move accepted")
    fired {
      ent:thid := event:attr("@id");
      ent:sender_order := 0;
      last;
      raise tictactoe event "initial_move" attributes {"move":move,"me":me}
    }
  }
  rule process_initial_move {
    select when tictactoe initial_move
      me re#^([XO])$# setting(me)
    pre {
      move = event:attr("move")
      attrs = {"them":ent:opponent}
    }
    if move.isnull() then noop()
    fired {
      raise ttt event "start_of_new_game" attributes attrs.put({"me": me})
    } else {
      raise ttt event "receive_move" attributes attrs.put({"move": move})
    }
  }
  rule handle_subsequent_moves {
    select when tictactoe move
      me re#^([XO])$# setting(me)
    pre {
      moves = event:attr("moves").decode()
      move = moves[moves.length()-1]
      attrs = {"them":ent:opponent}
    }
    fired {
      ent:thid := event:attr("~thread"){"thid"} if ent:thid.isnull();
      ent:sender_order := 0 if ent:sender_order.isnull();
      raise ttt event "receive_move" attributes attrs.put({"move": move})
    }
  }
//
// send move as basicmessage
//
  rule send_move_as_basicmessage {
    select when ttt:new_move_to_send
      where ent:their_vk
    pre {
      me = event:attr("me")
      moves = event:attr("moves")
      mm = tttMoveMap(me,moves,event:attr("comment"))
        .put("~thread",{"thid":ent:thid,"sender_order":ent:sender_order+1})
    }
    fired {
      raise sovrin event "send_basicmessage" attributes {
        "their_vk": ent:their_vk, "content": mm
      };
      ent:sender_order := ent:sender_order + 1
    }
  }
//
// handle game over
//
  rule handle_game_over {
    select when ttt game_over
      where ent:their_vk
    pre {
      om = tttOutcomeMap(event:attr("winner"),event:attr("comment"))
        .put("~thread",{"thid":ent:thid,"sender_order":ent:sender_order+1})
    }
    fired {
      raise sovrin event "send_basicmessage" attributes {
        "their_vk": ent:their_vk, "content": om
      };
      ent:sender_order := ent:sender_order + 1;
      raise tictactoe event "game_over"
    }
  }
//
// tictactoe/1.0/outcome
//
  rule handle_outcome_message {
    select when tictactoe outcome
    fired {
      raise tictactoe event "game_over"
    }
  }
//
// prepare for new game
//
  rule prepare_for_new_game {
    select when tictactoe game_over
    fired {
      clear ent:my_did;
      clear ent:opponent;
      clear ent:sender_order;
      clear ent:their_vk;
      clear ent:thid
    }
  }
}
