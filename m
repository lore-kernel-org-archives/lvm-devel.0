From: Petr Rockai <prockai@redhat.com>
Date: Tue, 31 Jul 2012 15:30:18 +0200
Subject: [PATCH] [RFC] Daemon logging functions
Message-ID: <871ujs9hxx.fsf@aldalome.mornfall.net>
	(sfid-20120731_153019_785750_C9501461)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have coded up some relatively minimal scaffolding for implementation
of logging in lvmetad. The patch should be mostly
self-explanatory... The main ideas:

- logging is not controlled by "levels" but by "types"; types are
  independent of each other... implementation of the usual "log level"
  can be simply done on top; the immediate application is
  enabling/disabling wire traffic logging independently of other debug
  data, since the former is rather bulky and can easily obscure almost
  everything else
- all logs go to "outlets", of which we currently have 2: syslog and
  stderr; which "types" go to which "outlets" is entirely configurable

Another feature of the log machinery is that a context needs to be
passed to each log function. While it is sometimes inconvenient, the
major upside is that there is no global state inherent in the log
layer. You can have multiple logging "contexts" in a single program,
configured differently.

Eventually, I would like to migrate non-daemon logging to use similar
principles, sharing some of the code. That would make it possible to
disable/enable different types of debug messages in all of LVM, making
debug logs much more readable when locally debugging specific issues. It
would hopefully also simplify and modularise the spaghetti monster
called "print_log".

-------------- next part --------------
A non-text attachment was scrubbed...
Name: daemon-log.diff
Type: text/x-patch
Size: 20062 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120731/0e40db9d/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
