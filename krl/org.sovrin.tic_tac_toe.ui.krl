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
    logo = "https://picolab.github.io/TicTacToe/200px-Tic_tac_toe.svg.png"
    css = <<<style type="text/css">
td {
border: 1px solid black;
height: 50px;
width: 50px;
vertical-align: middle;
text-align: center;
}
</style>
<link rel="shortcut icon" href="#{logo}">
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
    ui_html = function(moves){
      js = moves.map(function(m){
        player = m.substr(0,1)
        cell = m.split(":").tail().head()
        "document.getElementById('" + cell + "').innerHTML = '" + player + "'"
      })
      html:header("Tic Tac Toe",css)
      + board
      + <<<script type="text/javascript">
#{js.join(<<
>>)}
</script>
>>
      + html:footer()
    }
  }
}
