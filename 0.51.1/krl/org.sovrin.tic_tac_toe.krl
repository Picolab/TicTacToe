ruleset org.sovrin.tic_tac_toe {
  meta {
    use module org.sovrin.tic_tac_toe.ui alias ui
    shares __testing, state, them, html, is_winner
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "state" }
      , { "name": "them" }
      , { "name": "is_winner", "args": [ "player" ] }
      ] , "events":
      [ { "domain": "ttt", "type": "send_move", "attrs": [ "move", "them" ] }
      , { "domain": "ttt", "type": "receive_move", "attrs": [ "move" ] }
      , { "domain": "ttt", "type": "start", "attrs": [ "me", "move", "them" ] }
      , { "domain": "ttt", "type": "reset_requested" }
      ]
    }
    states = [ null, "my_move", "their_move", "wrap_up", "done" ]
    state = function(){
      states >< ent:state => ent:state
                           | "invalid state"
    }
    them = function(){
      ent:them
    }
    html = function(){
      ui:ui_html(
        ent:moves,
        ent:state,
        ent:me,
        ent:them,
        ent:winner,
        ent:protocol_rid,
        ent:possible_opponents_string.decode())
    }
    board = function(move){
      cell = move.extract(re#([A-C][1-3])$#).head();
      ent:moves >< "X:"+cell => "X" |
      ent:moves >< "O:"+cell => "O" |
      null
    }
    check_spec = function(spec,player){
      spec.all(function(s){board(s)==player})
    }
    specs = [
      ["A1", "A2", "A3"], ["B1", "B2", "B3"], ["C1", "C2", "C3"],
      ["A1", "B1", "C1"], ["A2", "B2", "C2"], ["A3", "B3", "C3"],
      ["A1", "B2", "C3"], ["A3", "B2", "C1"]
    ]
    is_winner = function(player){
      specs.any(function(s){s.check_spec(player)})
    }
  }
//
// capture protocol rid if any
//
  rule capture_protocol_rid_if_any {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    pre {
      proto_rid = event:attr("proto_rid")
    }
    if proto_rid then noop()
    fired {
      ent:protocol_rid := proto_rid
    }
  }
//
// update possible opponents
//
  rule update_possible_opponents {
    select when ttt possible_opponents_change
    fired {
      ent:possible_opponents_string := event:attr("possible_opponents").encode()
    }
  }
//
// initial configuration
//
  rule initial_configuration {
    select when ttt start
      me re#^([XO])$# setting(me)
    pre {
      move = event:attr("move")
    }
    fired {
      ent:them := event:attr("them");
      ent:me := me;
      ent:state := "their_move";
      ent:moves := move => [move] | [];
      clear ent:winner
    }
  }
//
// my initiative
//
  rule start_game {
    select when ttt send_move
       move re#^([XO]):[A-C][1-3]$# setting(player)
       where ent:state.isnull()
    fired {
      ent:them := event:attr("them");
      ent:me := player;
      ent:state := "my_move";
      ent:moves := [];
      clear ent:winner
    }
  }
  rule vet_move {
    select when ttt send_move move re#^([XO]):[A-C][1-3]$# setting(player)
    pre {
      right_player = player == ent:me
      right_state = ent:state == "my_move"
      message = not right_state => "It's not my turn" |
                not right_player => <<I am not "#{player}"" but "#{ent:me}">> |
                null
    }
    if message then send_directive("bad move",{"msg":message})
    fired {
      last
    }
  }
  rule check_for_duplicate {
    select when ttt send_move
      move re#^([XO]):([A-C][1-3])$# setting(player,move)
    pre {
      play = board(move)
      message = play.isnull() => null
              | move + " has already been played (as " + play + ")"
    }
    if message then send_directive("bad move",{"msg":message})
    fired {
      last
    }
  }
  rule make_move {
    select when ttt send_move move re#^([XO]:[A-C][1-3])$# setting(move)
    every {
      send_directive("moved "+move.split(":").tail().head(),
        {"next":<<#{meta:host}/sky/cloud/#{meta:eci}/#{meta:rid}/html.html>>})
    }
    fired {
      ent:moves := ent:moves.append(move);
      ent:state := "their_move";
      last;
      raise event "ttt:new_move_made";
      raise event "ttt:new_move_to_send" attributes {
        "me": ent:me, "moves": ent:moves
      }
    }
  }
  rule catch_all {
    select when ttt send_move
    send_directive("something is wrong")
  }
//
// their initiative
//
  rule join_and_start_game {
    select when ttt start_of_new_game
      me re#^([XO])# setting(player)
    fired {
      ent:them := event:attr("them");
      ent:me := player == "X" => "O" | "X";
      ent:state := "my_move";
      ent:moves := [];
      clear ent:winner
    }
  }
  rule join_starting_game {
    select when ttt receive_move
       move re#^([XO]:[A-C][1-3])$# setting(move)
       where ent:state.isnull()
    pre {
      player = move.substr(0,1)
    }
    fired {
      ent:them := event:attr("them");
      ent:me := player == "X" => "O" | "X";
      ent:state := "my_move";
      ent:moves := [move];
      clear ent:winner
    }
  }
  rule accept_their_move {
    select when ttt receive_move
      move re#^([XO]:[A-C][1-3])$# setting(move)
      where ent:state == "their_move"
    //TODO check everything; for now: be careful testing
    fired {
      ent:them := event:attr("them");
      ent:moves := ent:moves.append(move);
      ent:state := "my_move";
      raise event "ttt:new_move_made"
    }
  }
//
// check for outcome
//
  rule check_for_outcome {
    select when ttt:new_move_made
    pre {
      draw = ent:moves.length() >= 9
      winner = "X".is_winner() => "X"
             | "O".is_winner() => "O"
             | draw => "none"
             | null
    }
    if winner then
      send_directive("game over",{"winner":winner})
    fired {
      ent:state := "done";
      ent:winner := winner;
      raise ttt event "game_over" attributes {
        "winner": winner,
        "comment": draw => "Cat's game"
                 | winner == ent:me => "I won!"
                 | "You won!"
      }
    }
  }
//
// initialize for new game
//
  rule initialize_for_new_game {
    select when ttt:reset_requested
    pre {
      options = {
        "winner": "none",
        "comment": "abandonned"
      }
    }
    send_directive("game over",options)
    fired {
      clear ent:them;
      clear ent:me;
      clear ent:moves;
      clear ent:state;
      clear ent:winner;
      raise ttt event "game_over" attributes options
    }
  }
}
