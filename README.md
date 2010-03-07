Hector is a private group chat server that speaks a subset of the IRC protocol. It runs on [Ruby 1.8.7](http://ruby-lang.org/) and requires the [EventMachine](http://rubyeventmachine.com/) library.


### Chatting shouldn't be so complicated

Existing IRC servers are big, ugly, complex beasts. They're designed for large public networks that need to handle tens of thousands of concurrent connections. They're written in C so they're difficult to modify and often vulnerable to security exploits. Setting them up takes hours of configuration in special syntax and requires knowledge of jargon like "jupe" and "O-line."

Worse, they're hampered by years of legacy decisions. Access control and permissions are handled by an arcane set of user and channel modes and commands, enforced by "services bots" that need to be maintained separately from the servers themselves. And servers are encumbered with baby-sitting controls for rate limiting and spam protection because they're intended for public use.


### A private chat server for people you trust

Hector is different: it lets you create a private chat server for people you trust. It's designed for small groups of friends who are comfortable using an IRC client to talk to each other but don't want the administrative overhead of a public server.

Hector implements _just enough_ of the IRC protocol that existing IRC clients can connect and chat. Unlike other servers, Hector has no bans, modes, ops, opers, or channel keys -- but you do need a user name and password to connect. So you either have full access, or you don't have any access at all.

There are no administrative commands built into the server. You can grant or deny access to users with a simple command-line tool. If you need finer control over connections, use your operating system's firewall (or find better friends).

Modifying Hector is easy because it's written in Ruby. Implementing a new command is as simple as defining a method. Connecting Hector to your existing authentication system is straightforward too.


### Supported commands

Hector supports a limited subset of IRC commands.

- `USER` and `PASS` -- Authenticates you to the server. (Your client sends these as soon as it connects.)
- `NICK` -- Sets your nickname.
- `JOIN` -- Joins a channel.
- `PRIVMSG` and `NOTICE` -- Sends a message to another nickname or channel.
- `TOPIC` -- Changes or returns the topic of a channel.
- `NAMES` -- Shows a list of which nicknames are on a channel.
- `WHO` -- Like `NAMES`, but returns more information. (Your client probably sends this when it joins a channel.)
- `WHOIS` -- Shows information about a nickname, including how long it has been connected.
- `PART` -- Leaves a channel.
- `PING` -- Your client uses this command to measure the speed of its connection to the server.
- `QUIT` -- Disconnects from the server with an optional message.


### Installation and usage

For now, you'll need git, Ruby 1.8.7, and RubyGems.

    $ gem install -r eventmachine
    $ git clone git://github.com/sstephenson/hector.git
    $ cd hector
    $ bin/hector identity remember <yourusername> <yourpassword>
    $ bin/hector daemon

To run the tests, make sure you have the rake and mocha gems installed, then run `rake`.


### License (MIT)

Copyright © 2010 Sam Stephenson.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

