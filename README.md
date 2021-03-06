# TicTacToe
Aries-compatible implementation of Tic Tac Toe

Based on the [Tic Tac Toe Protocol 1.0](https://github.com/hyperledger/aries-rfcs/blob/master/concepts/0003-protocols/tictactoe/README.md) of the Aries project.

The protocol is there merely as "a way to demonstrate how all protocols should be documented."
However, it provides a useful sample KRL project of intermediate size,
and demonstrates the concept of an application running on top of DIDComm.

## Why a game? Why _this_ game?

First, because it is a well-known protocol.

More importantly, because it illustrates the value of using the DIDComm
`basicmessage` as a transport layer.
Messages are sent point-to-point, encrypted and signed.

## Prerequisites

This implementation uses Pico Agents¹ only.

> **Note that the Pico Agent code base is now deprecated, so this code needs to be re-written to use ACA-Pico agents.**

Picos are hosted on one (or more) pico-engines, which are owned and operated by someone.
The pico-engine must of course have support for Aries agents.
In addition to that, the owner/operator must install three rulesets² for this appliction.
The pico-engine operator must have also installed the 
[standalone UI for a Pico Agent](https://github.com/Picolab/pico-agent-ui).

A protocol plugin mechanism is involved, so the pico-engine must have
the `org.sovrin.didcomm_plugins` ruleset.

The two players (here Alice and Bob) each must be operating a Pico Agent,
and they must have established a connection before beginning to play.

## How the game is played

1. One person, say Alice, installs the `did-sov-SLfEi9esrjzybysFxQZbfq` ruleset into their Pico Agent³
1. With this ruleset installed, her Pico Agent UI shows the Tic Tac Toe plugin and its UI⁴ in the lower right corner
1. Alice proposes a game of Tic Tac Toe to Bob using the Tic Tac Toe embedded UI⁵
1. Upon receipt of the `basicmessage` from Alice, Bob's agent installs the ruleset and displays the UI⁶
1. They play as long as they want
1. To prepare to play another game, each clicks the "reset" button


## Notes

¹ [get Pico Agents here](https://github.com/Picolab/G2S) and your pico-engine MUST be at version 0.52.3 or higher

² To easily register these rulesets, visit [this page](https://picolab.github.io/TicTacToe/rids.html)

³ How to install the ruleset.
Visit the Rulesets tab of your agent pico.
Notice that it has the `org.sovrin.agent` ruleset, and the `org.sovrin.didcomm_plugins` ruleset.
Select the `did-sov-SLfEi9esrjzybysFxQZbfq` ruleset in the dropdown.
Click on the "install ruleset" button.

![Preparing to install the ruleset](https://picolab.github.io/TicTacToe/images/Step3a.png)

Note that installing the ruleset also causes the `io.picolabs.tic_tac_toe` ruleset to be installed.

![After installing the rulesets](https://picolab.github.io/TicTacToe/images/Step3b.png)

⁴ In her Pico Agent UI, Alices sees the plugin and its UI

![Alice's Tic Tac Toe UI](https://picolab.github.io/TicTacToe/images/Step4.png)

⁵ Alice starts the game by selecting Bob and clicking in the center

![Alice starts the game](https://picolab.github.io/TicTacToe/images/Step5.png)

⁶ Bob seeing the plugin and its UI

![Bob's Tic Tac Toe UI](https://picolab.github.io/TicTacToe/images/Step6.png)

