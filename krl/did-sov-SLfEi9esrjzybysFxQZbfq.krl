ruleset did-sov-SLfEi9esrjzybysFxQZbfq {
  meta {
    name "TicTacToe"
    description "tictactoe/1.0"
    use module org.sovrin.agent alias agent
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
    tttMoveMap = function(me,moves,comment){
      {
        "@type": "did:sov:SLfEi9esrjzybysFxQZbfq;spec/tictactoe/1.0/move",
        "~thread": { "thid":ent:thid, "sender_order": ent:sender_order },
        "me": me,
        "moves": moves,
        "comment": comment || "move " + moves[moves.length()-1]
      }
    }
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
  rule listen_in_on_basicmessage {
    select when sovrin basicmessage_message
    pre {
      their_key = event:attr("sender_key")
      conn = agent:connections(){their_key}
      msg = event:attr("message")
      content = msg.typeof()=="Map" => msg{"content"} | null
    }
    if content.typeof()=="Map" then noop()
    fired {
      raise basicmessage event "new_message" attributes content
      ent:opponent := conn{"label"}
      ent:their_vk := their_key
    }
  }
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
  rule handle_initial_move_message {
    select when tictactoe move
      me re#^([XO])$# setting(me)
      where event:attr("@id") && ent:thid.isnull()
    pre {
      moves = event:attr("moves").decode()
      initial_move = moves.typeof()=="Array"
                  && moves.length() <= 1
      move = moves.length()==0 => null | moves.head()
    }
    if initial_move then send_directive("initial move accepted")
    fired {
      ent:thid := event:attr("@id")
      ent:sender_order := 0
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
      where ent:thid
    pre {
      moves = event:attr("moves").decode()
      move = moves[moves.length()-1]
    }
    fired {
      raise ttt event "receive_move" attributes attrs.put({"move": move})
    }
  }
//
// send move as basicmessage
//
  rule send_move_as_basicmessage {
    select when ttt:new_move_to_send
    pre {
      me = event:attr("me")
      moves = event:attr("moves")
      mm = tttMoveMap(me,moves,event:attr("comment"))
    }
    fired {
      raise sovrin event "send_basicmessage" attributes {
        "their_vk": ent:their_vk, "content": mm
      }
      ent:sender_order := ent:sender_order + 1
    }
  }
}
