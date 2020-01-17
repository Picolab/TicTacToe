# TicTacToe
Aries-compatible implementation of Tic Tac Toe

Based on the [Tic Tac Toe Protocol 1.0](https://github.com/hyperledger/aries-rfcs/blob/master/concepts/0003-protocols/tictactoe/README.md) of the Aries project.

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
    1. She uses `tictactoe/start` event (in the Testing tab) to get an invitation message⁶
    1. She pastes the invitation into an agent message to the other⁷
1. They play as long as they want, using the comment system built into this protocol and/or the basicmessage protocol


Still to do:

- [x] detect end of game
- [x] use the actual protocol as the event attributes
- [ ] add an in-game comment facility?
- [ ] modify to allow agent-agent routing

¹ [get Pico Agents here](https://github.com/Picolab/G2S) and you'll need a pico-engine at version 0.52.3 or higher

² To easily register these rulesets, visit [this page](https://picolab.github.io/TicTacToe/rids.html)

³ How to install the ruleset. 
Visit the Rulesets tab of your agent pico. 
Notice that it has the `org.sovrin.agent` ruleset.
Select the `did-sov-SLfEi9esrjzybysFxQZbfq` ruleset in the dropdown. 
Click on the "install ruleset" button.

![Preparing to install the ruleset](https://picolab.github.io/TicTacToe/images/Step3a.png)

Note that installing the ruleset also causes an auxiliary ruleset to be installed.

![After installing the rulesets](https://picolab.github.io/TicTacToe/images/Step3b.png)

⁴ How to create a new channel.
Visit the Channels tab of your agent pico.
Notice that among the existing channels there is one for Alice as an agent and one for her DIDComm connection to Bob.

![Looking at the list of channels](https://picolab.github.io/TicTacToe/images/Step4a.png)

Name the new channel "tictactoe" and gives it a type of "ui".
Click the "new channel" button.

![Preparing to create a new channel](https://picolab.github.io/TicTacToe/images/Step4b.png)

The new channel which now appears in the list of channels.

![The new UI channel](https://picolab.github.io/TicTacToe/images/Step4c.png)

⁵ On the Testing tab, Alice first selects her new "tictactoe ui" channel. 
Then she opens up the tests for the ruleset. 
Finally she clicks on the "ui_url" link and opens a new window from the provided URL.
![Choosing the channel](https://github.com/Picolab/TicTacToe/blob/master/images/Step5a.png)
![Selecting the ruleset](https://github.com/Picolab/TicTacToe/blob/master/images/Step5b.png)
![Highlighting the provided URL](https://github.com/Picolab/TicTacToe/blob/master/images/Step5c.png)
![The Tic Tac Toe UI](https://github.com/Picolab/TicTacToe/blob/master/images/Step5d.png)

⁶ On the Testing tab, Alice selects her mark and an initial move.
She clicks on the "tictactoe/start" button and copies the provided message.
Refreshing her UI will show that she has made a first move and that the next move is her adversary's
(who has yet to be identified).
![Generating an initial message](https://github.com/Picolab/TicTacToe/blob/master/images/Step6.png)
![Refreshed UI](https://github.com/Picolab/TicTacToe/blob/master/images/Step6b.png)

⁷ On the Agent tab, Alice pastes the initial message and sends it to Bob.
Only the "comment" portion of the message shows in the conversation history.
Finally, Bob's UI is shown.
![Pasting the initial message](https://github.com/Picolab/TicTacToe/blob/master/images/Step7.png)
![Conversation history](https://github.com/Picolab/TicTacToe/blob/master/images/Step7b.png)

![The adversary's UI](https://github.com/Picolab/TicTacToe/blob/master/images/Step7c.png)

