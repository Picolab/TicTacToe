ruleset org.sovrin.tic_tac_toe.ui {
  meta {
    use module html
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
    make_clickable_js = function(state,me){
      send_move = <<#{meta:host}/sky/event/#{meta:eci}/move/ttt/send_move>>
      state == "my_move" => <<
$('td:empty').each(function(){
  $(this).addClass('p')
  .click(function(){
    $.getJSON('#{send_move}',{move:'#{me}:'+this.id},function(d){
      location.reload()
    })
  })
})>> | ""
    }
    ui_html = function(moves,state,me,them,winner){
      mark_cells_js = moves.isnull() => [] | moves.map(function(m){
        player = m.substr(0,1)
        cell = m.split(":").tail().head()
        "$('#" + cell + "').text('" + player + "')"
      }).join(new_line)
      js = moves => <<<script type="text/javascript">
#{mark_cells_js}#{make_clickable_js(state,me)}
</script>
>> | ""
      html:header("Tic Tac Toe",css)
      + <<<h1>Tic Tac Toe</h1>
<p>Playing: #{them}</p>
<p>State: #{state}#{state=="done" => " (winner: "+winner+")" | ""}</p>
<p>I am: #{me}</p>
>>
      + board
      + <<<p>Moves: #{moves.encode()}</p>
>>
      + js
      + html:footer()
    }
  }
}
