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
table.game td {
border: 1px solid black;
height: 50px;
width: 50px;
vertical-align: middle;
text-align: center;
}
table.game td.p { cursor: pointer; }
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
    board = <<<table class="game">
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
    choose_opponent = function(opp){
      item = function(a,k){a+<<<option value="#{k}">#{opp{k}}</option>
>>};
      <<<select id="them">
<option value="">choose a connection</option>
#{opp => opp.keys().reduce(item,"") | ""}
</select>
>>
    }
    choose_mark = <<<select id="me">
<option selected>X</option>
<option>O</option>
</select>
<button id="s">Let them move first</button>
>>
    make_clickable_js = function(state,me,proto_rid){
      send_ttt = <<#{meta:host}/sky/event/#{meta:eci}/move/ttt>>;
      start_msg = <<#{meta:host}/sky/cloud/#{meta:eci}/#{proto_rid}/start_message>>;
      start_js = <<$.getJSON('#{start_msg}',{me:me,move:move},function(d){
        $.getJSON('#{meta:host}/sky/event/#{meta:eci}/prime/sovrin/send_basicmessage',
          {their_vk:$('#them').val(),content:d},
          function(){location.reload()})
      })>>;
      state == "my_move" || state.isnull() => <<
$('td:empty').each(function(){
  $(this).addClass('p')
  .click(function(){
    var me = #{me.isnull() => "$('#me').val()" | <<'#{me}'>>}
    var move = me + ':' + this.id
    var attrs = {move:move}
#{state.isnull() => <<
    var them = $('#them option:selected').text()
    if(them.length===0) return
    attrs.them = them
>> | ""}
    $.getJSON('#{send_ttt}/send_move',attrs,function(d){
      #{proto_rid && state.isnull() => start_js | "location.reload()"}
    })
  })
})
#{state.isnull() => <<//handle button#s
$('button#s').click(function(){
  var me = $('#me').val()
  var move = []
  var them = $('#them option:selected').text()
  if(them.length===0) return
  $.getJSON('#{send_ttt}/start',{me:me,them:them},function(){
    #{proto_rid => start_js | ""}
  })
})>> | ""}>> | ""}
    poll_js = function(){
      rid = "org.sovrin.tic_tac_toe";
      poll_state = <<#{meta:host}/sky/cloud/#{meta:eci}/#{rid}/state>>;
      <<//wait for them to move
var timer
var poll_setup = function(){
  if (timer) clearTimeout(timer)
  var f1 = 0
  var f2 = 0
  var poll = function(sec){
    $('#sec').text(sec==1 ? "1 second" : sec + " seconds")
    timer = setTimeout(function(){
      $.getJSON('#{poll_state}',function(d){
        if(d=="my_move" || d=="done") location.reload()
        f1 = f2
        f2 = sec
        var fn = f1 + f2
        if (!document.hidden && fn<86400) poll(fn)
      })
    },sec*1000)
  }
  poll(1)
}
document.addEventListener('visibilitychange', function() {
  if (!document.hidden) poll_setup()}, false)
document.addEventListener('mouseover', function() {poll_setup()}, false)
poll_setup()
>>
    }
    reset_js = function(state){
      reset = <<#{meta:host}/sky/event/#{meta:eci}/reset/ttt/reset_requested>>;
      state.isnull() => "" | <<$('button#x').click(function(){
  $.getJSON('#{reset}',function(d){
    location.reload()
  })
})
>>}
    ui_html = function(moves,state,me,them,winner,proto_rid,opp){
      mark_cells_js = (moves.isnull() => [] | moves)
      .map(function(m){
        player = m.substr(0,1);
        cell = m.split(":").tail().head();
        "$('#" + cell + "').text('" + player + "')"
      }).join(new_line);
      js = <<<script type="text/javascript">
#{mark_cells_js}
#{make_clickable_js(state,me,proto_rid)}
#{state=="their_move" || state.isnull() => poll_js() | ""}
#{reset_js(state)}
</script>
>>;
      html:header("Tic Tac Toe",css)
      + <<<h1>Tic Tac Toe</h1>
<h2>#{wrangler:name()}</h2>
<p>Playing: #{them => them | choose_opponent(opp)}</p>
<p>State: #{state}#{state=="done" => " (winner: "+winner+")" | ""}</p>
<p>I am: #{state.isnull() => choose_mark | me}</p>
>>
      + board
      + <<<p>Moves: #{moves.encode()}</p>
>>
      + (state.isnull() => "" | <<<button id="x">reset</button>
>>)
      + (state=="their_move" || state.isnull() =>
          <<<p>checking in <span id="sec"></span></p>
>> | "")
      + js
      + html:footer()
    }
  }
}
