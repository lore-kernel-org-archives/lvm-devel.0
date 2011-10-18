From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Oct 2011 16:27:46 -0000
Subject: LVM2/tools commands.h
Message-ID: <20111018162746.10662.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-18 16:27:46

Modified files:
	tools          : commands.h 

Log message:
	Fix bad lvconvert help output.
	
	The '--merge' option to lvconvert works on snapshots and RAID1.  The man
	pages correctly reflect this, but the CLI help output still used the term,
	'SnapshotLogicalVolume'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/tools/commands.h	2011/10/07 14:52:27	1.164
+++ LVM2/tools/commands.h	2011/10/18 16:27:45	1.165
@@ -137,7 +137,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-v|--verbose]\n"
-   "\tSnapshotLogicalVolume[Path]\n",
+   "\tLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,


