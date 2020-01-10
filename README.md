# TicTacToe
Aries-compatible implementation of Tic Tac Toe

Based on the [Tic Tac Toe Protocol 1.0](https://github.com/Picolab/TicTacToe) of the Aries project.

The protocol is there merely as "a way to demonstrate how all protocols should be documented." However, it provides a useful sample KRL project of intermediate size.

So far there is just the basics of the game itself.

Still to do:

- [ ] detect end of game
- [ ] use the actual protocol as the event attributes
- [ ] use DID from one of the agent's pre-existing connections

It is intended for use as follows:

1. Bob and Alice have an Aries DIDComm connection, both using Pico Agents
1. One proposes a game of Tic Tac Toe to the other through the `basicmessage` protocol
1. Each registers the `org.sovrin.tic_tac_toe` and `org.sovrin.tic_tac_toe.ui` rulesets in the pico-engine hosting their picos
1. Each intalls the `org.sovrin.tic_tac_toe` ruleset into their agent pico
1. They play as long as they want, using the comment system built into this protocol and/or the basicmessage protocol

To easily register these rulesets, visit [this page](https://picolab.github.io/TicTacToe/rids.html)
