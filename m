From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Feb 2007 16:04:02 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf man/lvchange ...
Message-ID: <20070213160402.1612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-13 16:04:01

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	man            : lvchange.8 pvmove.8 

Log message:
	Correct -b and -P on a couple of man pages.
	Add global/units to example.conf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.571&r2=1.572
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2007/02/08 17:31:02	1.571
+++ LVM2/WHATS_NEW	2007/02/13 16:04:01	1.572
@@ -1,5 +1,7 @@
 Version 2.02.22 - 
 ===================================
+  Correct -b and -P on a couple of man pages.
+  Add global/units to example.conf.
   Fix loading of segment_libraries.
   If a PV reappears after it was removed from its VG, make it an orphan.
   Don't update metadata automatically if VGIDs don't match.
--- LVM2/doc/example.conf	2007/01/25 21:22:30	1.28
+++ LVM2/doc/example.conf	2007/02/13 16:04:01	1.29
@@ -188,6 +188,9 @@
     # command.  Defaults to off.
     test = 0
 
+    # Default value for --units argument
+    units = "h"
+
     # Whether or not to communicate with the kernel device-mapper.
     # Set to 0 if you want to use the tools to manipulate LVM metadata 
     # without activating any logical volumes.
--- LVM2/man/lvchange.8	2006/10/24 17:18:24	1.11
+++ LVM2/man/lvchange.8	2007/02/13 16:04:01	1.12
@@ -12,7 +12,7 @@
 [\-\-ignorelockingfailure]
 [\-\-monitor {y|n}]
 [\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-P/\-\-partial y/n]
+[\-P/\-\-partial]
 [\-p/\-\-permission r/w] [\-r/\-\-readahead ReadAheadSectors]
 [\-\-refresh]
 [\-t/\-\-test]
--- LVM2/man/pvmove.8	2004/11/16 18:09:31	1.5
+++ LVM2/man/pvmove.8	2007/02/13 16:04:01	1.6
@@ -5,7 +5,7 @@
 .B pvmove
 [\-\-abort]
 [\-\-alloc AllocationPolicy]
-[\-\-background]
+[\-b/\-\-background]
 [\-d/\-\-debug] [\-h/\-\-help] [\-i/\-\-interval Seconds] [\-v/\-\-verbose]
 [\-n/\-\-name LogicalVolume] 
 [SourcePhysicalVolume[:PE[-PE]...] [DestinationPhysicalVolume[:PE[-PE]...]...]]
@@ -73,7 +73,7 @@
 .I \-\-abort
 Abort any moves in progress.
 .TP
-.I \-\-background
+.I \-b, \-\-background
 Run the daemon in the background.
 .TP
 .I \-i, \-\-interval Seconds


