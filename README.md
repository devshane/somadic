# Somadic

Somadic is a bare-bones terminal-based player for somafm.com and di.fm. It uses `mplayer` to
do the heavy lifting.

There are two clients: `somadic` is a simple single-line display:

```
$ somadic soma secretagent130

[secretagent130] 23:13 Goblin - Profondo Rosso Death Dies M32
[secretagent130] 23:18 Henry Mancini - Llujon [DJ Cam Remaster]
```

`somadic-curses` displays more information like up/down votes, progress, and track times.

```
$ somadic-curses di breaks

[ breaks ][ Rave CHannel - Te Quiero (AMase Breaks Mix)                 ][ 00:25 / 07:38 ]
[######..................................................................................]
: Beware of Pickpockets - Nimbus (Original Mix)                                    05:27 :
: Deekline - 01NIGHT MOODS ORIGIONAL MIMAI BASS MIX                      : +0/-1 : 03:29 :
: Benny Benassi - Satisfaction (DirTy MaN Mix)                                     04:40 :
: Vetoo - Recall (Refracture Remix)                                                05:40 :
: Firebeatz feat Schella - Dear New York (Barrera Breaks Mix)                      05:07 :
: Quade - Quade Character Dephicit Remix Original Mix                              04:54 :
: Ils - 589027 Lone Riders Def Inc  Remix                                : +1/-0 : 06:48 :

```

## Installation

Clone the repo:

    $ git clone https://github.com/devshane/somadic.git

Build the gem:

    $ gem builde somadic.gemspec

Install the gem:

    $ gem install somadic-0.0.1.gem

## Usage

```
Usage: somadic [options] site channel

The `site` parameter can be di or soma. The `channel` parameter should be a valid channel.

DI premium channels require an environment variable: DI_FM_PREMIUM_ID.

    -c, --cache CACHE_SIZE           Set the cache size (KB)
    -m, --cache-min CACHE_MIN        Set the minimum cache threshold (percent)
    -h, --help                       Display this message
```

#### Examples

```
# Listen to breaks on DI
$ somadic di breaks

# Or to use the Curses client, which is a bit more featured:
$ somadic-curses di breaks
```

## Contributing

1. Fork it ( http://github.com/devshane/somadic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
