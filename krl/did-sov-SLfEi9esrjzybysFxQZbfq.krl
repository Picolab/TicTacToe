ruleset did-sov-SLfEi9esrjzybysFxQZbfq {
  meta {
    name "TicTacToe"
    description "tictactoe/1.0"
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":
      [ { "domain": "tictactoe", "type": "initial_move", "attrs": [ "me" ] }
      , { "domain": "tictactoe", "type": "initial_move", "attrs": [ "me","move" ] }
      ]
    }
    mturi = re#did:sov:SLfEi9esrjzybysFxQZbfq;spec/tictactoe/1.0/([A-Za-z0-9_.-]+)#
  }
//
// bookkeeping
//
  rule initialize_a_router {
    select when wrangler ruleset_added where event:attr("rids") >< meta:rid
    fired {
      raise wrangler event "install_rulesets_requested"
        attributes {"rid":"org.sovrin.tic_tac_toe"}
    }
  }
//
// agent basicmessage handler
//
  rule accept_new_message {
    select when basicmessage new_message
      where event:attr("@type").match(mturi)
    pre {
      message_type = event:attr("@type").extract(mturi).head()
    }
    fired {
      last
      raise tictactoe event message_type attributes event:attrs
    }
  }
  rule catch_bad_message {
    select when basicmessage new_message
    send_directive("bad message")
  }
//
// tictactoe/1.0/move
//
  rule store_thread_id {
    select when tictactoe move where ent:thid.isnull()
    fired {
      ent:thid := event:attr("@id")
    }
  }
  rule handle_initial_move_message {
    select when tictactoe move
      me re#^([XO])$# setting(me)
      where event:attr("@id")
    pre {
      moves = event:attr("moves").decode()
      initial_move = moves.istype("Array")
                  && moves.length() <= 1
      move = moves.length()==0 => null | moves.head()
    }
    if initial_move then send_directive("initial move accepted")
    fired {
      raise tictactoe event "initial_move" attributes {"move":move,"me":me}
    }
  }
  rule process_initial_move {
    select when tictactoe initial_move
      me re#^([XO])$# setting(me)
    pre {
      move = event:attr("move")
    }
    if move.isnull() then noop()
    fired {
      raise ttt event "start_of_new_game" attributes {"me": me}
    } else {
      raise ttt event "receive_move" attributes {"move": move}
    }
  }
}
