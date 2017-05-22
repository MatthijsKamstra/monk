# Monk

![](icon.png)

## TL;DR

Monk is a photo focussed static site generator.

## Tell me more!

Written in Haxe but eventually usuable for more languages.

**Why Monk?** Writing a website like this is complex and slower then CMS, so it feld a little like the old European Monk copying books.
But they are not as cool as Shaulin Monks so there might be some references to those monks.

## WIP

I use this to generate the homepage of [matthijskamstra.nl](http://www.matthijskamstra.nl).

This fixes a very specific need I have, not fixed by others generators. That doesn't mean they aren't good, just not in this case.

I use a quick and dirty approach to get stuff done. Not readable, might change in the future.
The more I work on it, the better it will become.

## sources

This first "hit" I got was Expose, so Monk is heavily inspired by the work of Jack Qiao
- <https://github.com/Jack000/Expose>

I have work on and with Butterfly before and because of that I use a lot from that generator:
- <https://github.com/ashes999/butterfly>



## folder structure


```
+ folder
	- config.json
	+ img
	+ pages
	+ photo
	+ post
	+ theme0
	+ www
```


## folders read

- post folder only that folder...
- pages folder only that folder
- photos folder and one folder deeper

```
+ photos
	+ folder00
	+ folder01
	+ folder02
```

## tools

- <https://www.imagemagick.org/script/index.php>

## Usage

Currently I am only using Monk via haxelib

```bash
haxelib run monk
haxelib run monk generate
```

That might change to

- command line
- nodejs
- and other target by Haxe


### Config


```
{"site_title":"MONK","social_button":false,"backgroundcolor":"#000000","theme_dir":"theme0"}
```



## reminder!

the folder sorted as first (either `alpha` or `00_zebra`) wil be the first images you will see on the homepage!

### sort photo folders

how to sort folders

create folder with `00` -> `99`  and add `_` to use default folder sort.

example:
```
	+ 00_ccc
	+ 01_bbb
	+ 03_aaa
```

will create the photo menu

```
	+ ccc
	+ bbb
	+ aaa
```


### Meta-data


### Tips

Folders or files you want to ignore, prefix with an `_` or `.`

Rename folder `foo` to `_foo` and it will be ignored.
The same will happen with files: rename `test.md` to `_test.md` and it will not be used be MONK.





# Haxe

This is a [Haxe](http://www.haxe.org) project, read more about it in the [README_HAXE.MD](README_HAXE.MD)!
