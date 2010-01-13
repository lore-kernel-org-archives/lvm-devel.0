From: Petr Rockai <prockai@redhat.com>
Date: Wed, 13 Jan 2010 20:45:38 +0100
Subject: [PATCH] dmeventd logging
Message-ID: <878wc1eql9.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch makes dmeventd bridge the LVM log output to
syslog. If you run dmeventd as usual, only warnings and errors from LVM
will be sent to syslog, using appropriate syslog levels. If you pass -D
or -d to dmeventd (first will run it in daemon mode, second in
foreground), all LVM logging, up to notices (I believe this corresponds
to log_very_verbose, but I haven't checked), will be sent to syslog,
using the LOG_DEBUG level.

If we can get thusly patched dmeventd, with -D, running on Corey's test
cluster, this should bring some insight into the lvconvert --repair
failures we have been seeing on cmirror. Without -D, this should still
be helpful when diagnosing problems on customers' systems.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-logging.diff
Type: text/x-diff
Size: 3617 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100113/12b2ad1c/attachment.bin>
