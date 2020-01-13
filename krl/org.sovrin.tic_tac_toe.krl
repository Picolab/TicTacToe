ruleset org.sovrin.tic_tac_toe {
  meta {
    use module org.sovrin.agent alias agent
    use module org.sovrin.tic_tac_toe.ui alias ui
    shares __testing, state, opponents, html
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "state" }
      , { "name": "opponents", "args": [ "label" ] }
      ] , "events":
      [ { "domain": "ttt", "type": "send_move", "attrs": [ "move" ] }
      , { "domain": "ttt", "type": "receive_move", "attrs": [ "move" ] }
      ]
    }
    states = [ null, "my_move", "their_move", "wrap_up", "done" ]
    state = function(){
      states >< ent:state => ent:state
                           | "invalid state"
    }
    opponents = function(label){
      want = [ "label", "their_did" ]
      simplify = function(c){c.filter(function(v,k){want><k})}
      c_array = label => [agent:connections(label)]
                       | agent:connections().values()
      c_array.length() == 1 && c_array[0].isnull()
        => []
         | c_array.map(simplify)
    }
    html = function(){
      ui:ui_html(ent:moves)
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
      ent:me := player
      ent:state := "my_move"
      ent:moves := []
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
      cell = function(m){m.split(":").tail().head()}
      bad = ent:moves.filter(function(x){move==cell(x)})
      message = bad.length() == 0 => null
              | move + " has already been played (as " + bad.head().substr(0,1) + ")"
    }
    if message then send_directive("bad move",{"msg":message})
    fired {
      last
    }
  }
  rule make_move {
    select when ttt send_move move re#^([XO]:[A-C][1-3])$# setting(move)
    every {
      //actually _make_ the move
      send_directive("moved "+move.split(":").tail().head())
    }
    fired {
      ent:moves := ent:moves.append(move)
      ent:state := "their_move"
      last
    }
  }
  rule catch_all {
    select when ttt send_move
    send_directive("something is wrong")
  }
//
// their initiative
//
  rule join_starting_game {
    select when ttt receive_move
       move re#^([XO]:[A-C][1-3])$# setting(move)
       where ent:state.isnull()
    pre {
      player = move.substr(0,1)
    }
    fired {
      ent:me := player == "X" => "O" | "X"
      ent:state := "my_move"
      ent:moves := [move]
    }
  }
  rule accept_their_move {
    select when ttt receive_move
      move re#^([XO]:[A-C][1-3])$# setting(move)
      where ent:state == "their_move"
    //TODO check everything; for now: be careful testing
    fired {
      ent:moves := ent:moves.append(move)
      ent:state := "my_move"
    }
  }
}
