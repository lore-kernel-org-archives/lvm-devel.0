From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 17:19:48 -0000
Subject: LVM2/tools commands.h
Message-ID: <20061024171948.19593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 17:19:48

Modified files:
	tools          : commands.h 

Log message:
	resync alphabetical order

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/tools/commands.h	2006/10/24 17:18:25	1.90
+++ LVM2/tools/commands.h	2006/10/24 17:19:48	1.91
@@ -61,7 +61,6 @@
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
-   "\t[--resync]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--monitor {y|n}]\n"
@@ -70,6 +69,7 @@
    "\t[-p|--permission r|rw]\n"
    "\t[-r|--readahead ReadAheadSectors]\n"
    "\t[--refresh]\n"
+   "\t[--resync]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
@@ -77,8 +77,8 @@
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   resync_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
-   partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
+   ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
+   partial_ARG, permission_ARG, persistent_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,


