# TicTacToe
Aries-compatible implementation of Tic Tac Toe

Based on the [Tic Tac Toe Protocol 1.0](https://github.com/Picolab/TicTacToe) of the Aries project.

The protocol is there merely as "a way to demonstrate how all protocols should be documented." However, it provides a useful sample KRL project of intermediate size.

So far there is just the basics of the game itself.

Still to do:

- [x] detect end of game
- [x] use the actual protocol as the event attributes
- [ ] add an in-game comment facility?
- [ ] modify to allow agent-agent routing

It is intended for use as follows:

1. Bob and Alice have an Aries DIDComm connection, both using Pico Agents [get Pico Agents here](https://github.com/Picolab/G2S)
1. Each registers three rulesets in the pico-engine hosting their picos
1. Each intalls the `did-sov-SLfEi9esrjzybysFxQZbfq` ruleset into their agent pico
1. Each creates a channel for game play
1. Each uses the Testing tab to get a UI URL and opens in a window
1. One proposes a game of Tic Tac Toe to the other through the `basicmessage` protocol
    1. She uses `tictactoe/start` event to get an invitation message
    1. She pastes the invitation into an agent message to the other
1. They play as long as they want, using the comment system built into this protocol and/or the basicmessage protocol

To easily register these rulesets, visit [this page](https://picolab.github.io/TicTacToe/rids.html)
