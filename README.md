# TicTacToe
Aries-compatible implementation of Tic Tac Toe

Based on the [Tic Tac Toe Protocol 1.0](https://github.com/Picolab/TicTacToe) of the Aries project.

The protocol is there merely as "a way to demonstrate how all protocols should be documented." 
However, it provides a useful sample KRL project of intermediate size, 
and demonstrates the concept of an application running on top of DIDComm.

It is intended for use as follows:

1. Bob and Alice have an Aries DIDComm connection, both using Pico Agents¹
1. Each registers three rulesets in the pico-engine hosting their picos²
1. Each intalls the `did-sov-SLfEi9esrjzybysFxQZbfq` ruleset into their agent pico³
1. Each creates a channel for game play⁴
1. Each uses the Testing tab to get a UI URL to open in a window⁵
1. One proposes a game of Tic Tac Toe to the other through the `basicmessage` protocol
    1. She uses `tictactoe/start` event (in the Testing tab) to get an invitation message
    1. She pastes the invitation into an agent message to the other
1. They play as long as they want, using the comment system built into this protocol and/or the basicmessage protocol


Still to do:

- [x] detect end of game
- [x] use the actual protocol as the event attributes
- [ ] add an in-game comment facility?
- [ ] modify to allow agent-agent routing

¹ [get Pico Agents here](https://github.com/Picolab/G2S) and you'll need a pico-engine at version 0.52.3 or higher

² To easily register these rulesets, visit [this page](https://picolab.github.io/TicTacToe/rids.html)

³ See these before and after screenshots. Note that installing the ruleset also causes an auxiliary ruleset to be installed.
![Preparing to install the ruleset](https://github.com/Picolab/TicTacToe/blob/master/images/Step3a.png)
![After installing the rulesets](https://github.com/Picolab/TicTacToe/blob/master/images/Step3b.png)

⁴ See screenshot below showing the channels before this begins.
Notice that among the existing channels there is one for Alice as an agent and one for her DIDComm connection to Bob.
Then Alice names the new channel "tictactoe" and gives it a type of "ui".
Finally, she creates the new channel which now appears in the list of channels.
![Looking at the list of channels](https://github.com/Picolab/TicTacToe/blob/master/images/Step4a.png)
![Preparing to create a new channel](https://github.com/Picolab/TicTacToe/blob/master/images/Step4b.png)
![The new UI channel](https://github.com/Picolab/TicTacToe/blob/master/images/Step4c.png)

⁵ On the Testing tab, Alice first selects her new "tictactoe ui" channel. 
Then she opens up the tests for the ruleset. 
Finally she clicks on the "ui_url" link and opens a new window from the provided URL.
![Choosing the channel](https://github.com/Picolab/TicTacToe/blob/master/images/Step5a.png)
![Selecting the ruleset](https://github.com/Picolab/TicTacToe/blob/master/images/Step5b.png)
![Highlighting the provided URL](https://github.com/Picolab/TicTacToe/blob/master/images/Step5c.png)

