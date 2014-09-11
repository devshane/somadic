# Somadic

Somadic is a bare-bones terminal-based player for [somafm.com](http://somafm.com) and [di.fm](http://di.fm). 
It uses `mplayer` to do the heavy lifting.

```
$ somadic-curses di:breaks

[ breaks ][ Rave Channel - Te Quiero (Amase Breaks Mix)                 ][ 00:25 / 07:38 ]
[######..................................................................................]
: Beware of Pickpockets - Nimbus (Original Mix)                                    05:27 :
: Deekline - 01NIGHT MOODS ORIGIONAL MIMAI BASS MIX                      : +0/-1 : 03:29 :
: Benny Benassi - Satisfaction (DirTy MaN Mix)                                     04:40 :
: Vetoo - Recall (Refracture Remix)                                                05:40 :
: Firebeatz feat Schella - Dear New York (Barrera Breaks Mix)                      05:07 :
```

## Installation

```
$ gem install somadic
```

## Usage

```
Usage: somadic [options] [preset_name | [site1:channel1 ...]]

You can specify either a `preset_name` or an arbitrary list of `site:channel` identifiers.

  site: either `di` or `soma`
  channel: a valid channel on `site`

DI premium channels require an environment variable: DI_FM_PREMIUM_ID.

    -c, --cache CACHE_SIZE           Set the cache size (KB)
    -m, --cache-min CACHE_MIN        Set the minimum cache threshold (percent)
    -h, --help                       Display this message
```

#### Valid keys

```
n       - Next site:channel in list
N       - Pick a random channel from `site`
q       - Quit
r       - Refresh the display
s       - Search Google for the current track
<space> - Start/stop playing current channel
/       - Goto site:channel
```

#### Presets

You can create preset files rather than listing multiple channels on the command line. Create
a YAML file in `~/.somadic/presets`, say `chill.yaml`, with the following content:

```
---
- di:breaks
- soma:secretagent
- di:psychill
- soma:lush
```

You can then start somadic with the preset's name:

```
$ somadic chill
```

#### Examples

**Listen to breaks on DI**
```
$ somadic di:breaks
```

**Listen to breaks, psychill, and secret agent**
```
$ somadic di:breaks di:psychill soma:secretagent
```

**Listen to the chill preset (assumes a ~/.somadic/presets/chill.yaml file)**
```
$ somadic chill
```

## Contributing

1. Fork it ( http://github.com/devshane/somadic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
