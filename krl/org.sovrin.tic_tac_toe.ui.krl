ruleset org.sovrin.tic_tac_toe.ui {
  meta {
    use module html
    use module io.picolabs.wrangler alias wrangler
    provides ui_html
    shares __testing
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "ui_html", "args": [ "moves" ] }
      ] , "events":
      [ //{ "domain": "d1", "type": "t1" }
      //, { "domain": "d2", "type": "t2", "attrs": [ "a1", "a2" ] }
      ]
    }
    new_line = <<
>>
    logo = "https://picolab.github.io/TicTacToe/200px-Tic_tac_toe.svg.png"
    css = <<<style type="text/css">
td {
border: 1px solid black;
height: 50px;
width: 50px;
vertical-align: middle;
text-align: center;
}
td.p { cursor: pointer; }
#A1 { border-left: white; border-top: white; }
#A2 { border-left: white; }
#A3 { border-left: white; border-bottom: white; }
#B3 { border-bottom: white; }
#C3 { border-bottom: white; border-right: white; }
#C2 { border-right: white; }
#C1 { border-top: white; border-right: white; }
#B1 { border-top: white; }
</style>
<link rel="shortcut icon" href="#{logo}">
<script src="/js/jquery-3.1.0.min.js" type="text/javascript"></script>
>>
    board = <<<table>
    <tr>
        <td id="A1"></td>
        <td id="B1"></td>
        <td id="C1"></td>
    </tr>
    <tr>
        <td id="A2"></td>
        <td id="B2"></td>
        <td id="C2"></td>
    </tr>
    <tr>
        <td id="A3"></td>
        <td id="B3"></td>
        <td id="C3"></td>
    </tr>
</table>
>>
    choose = <<<select id="me">
<option selected>X</option>
<option>O</option>
</select>
>>
    make_clickable_js = function(state,me){
      send_move = <<#{meta:host}/sky/event/#{meta:eci}/move/ttt/send_move>>
      proto_rid = "did-sov-SLfEi9esrjzybysFxQZbfq"
      start_msg = <<#{meta:host}/sky/cloud/#{meta:eci}/#{proto_rid}/start_message>>
      start_js = <<$.getJSON('#{start_msg}',{me:me,move:move},function(d){
        if(confirm(JSON.stringify(d))) location.reload()
      })>>
      state == "my_move" || state.isnull() => <<
$('td:empty').each(function(){
  $(this).addClass('p')
  .click(function(){
    var me = #{me.isnull() => "$('#me').val()" | <<'#{me}'>>}
    var move = me + ':' + this.id
    $.getJSON('#{send_move}',{move:move},function(d){
      #{state.isnull() => start_js | "location.reload()"}
    })
  })
})
>> | ""}
    reset_js = function(state){
      reset = <<#{meta:host}/sky/event/#{meta:eci}/move/ttt/reset_requested>>
      state.isnull() => "" | <<$('button.x').click(function(){
  $.getJSON('#{reset}',function(d){
    location.reload()
  })
})
>>}
    ui_html = function(moves,state,me,them,winner){
      mark_cells_js = (moves.isnull() => [] | moves)
      .map(function(m){
        player = m.substr(0,1)
        cell = m.split(":").tail().head()
        "$('#" + cell + "').text('" + player + "')"
      }).join(new_line)
      js = <<<script type="text/javascript">
#{mark_cells_js}
#{make_clickable_js(state,me)}
#{reset_js(state)}
</script>
>>
      html:header("Tic Tac Toe",css)
      + <<<h1>Tic Tac Toe</h1>
<h2>#{wrangler:name()}</h2>
<p>Playing: #{them}</p>
<p>State: #{state}#{state=="done" => " (winner: "+winner+")" | ""}</p>
<p>I am: #{state.isnull() => choose | me}</p>
>>
      + board
      + <<<p>Moves: #{moves.encode()}</p>
>>
      + (state.isnull() => "" | <<<button id="x">reset</button>
>>)
      + js
      + html:footer()
    }
  }
}
