From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 10:58:41 -0000
Subject: LVM2/man lvchange.8.in
Message-ID: <20090803105841.24659.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 10:58:41

Modified files:
	man            : lvchange.8.in 

Log message:
	lvchange --noudevsync

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/lvchange.8.in	2008/11/12 15:01:36	1.3
+++ LVM2/man/lvchange.8.in	2009/08/03 10:58:40	1.4
@@ -12,6 +12,7 @@
 [\-\-ignorelockingfailure]
 [\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
+[\-\-noudevsync]
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-P|\-\-partial]
 [\-p|\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
@@ -61,6 +62,13 @@
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
+.I \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .I \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless \-\-monitor
 is specified.


