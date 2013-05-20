GregariusMenu
=============

[Project's site](https://goddess-gate.com/projects/en/osx/gregariusmenu)

Description
-----------

GregariusMenu is a tool within Mac OS X menubar (at least 10.5), and displaying unread [Gregarius](http://sourceforge.net/projects/gregarius/)' posts count.

GregariusMenu is available under the terms of [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0.txt).

Automatic update of Gregarius RSS feed script example
-----------------------------------------------------

With FreeBSD, I used :

`#!/bin/sh`

`cd /path/to/gregarius/`

`/usr/local/bin/php -f update.php silent`

The script is executed every 30 minutes by the crontab entry

`*/30 * * * * root /opt/refresh_gregarius.sh`