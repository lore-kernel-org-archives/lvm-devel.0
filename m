From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 14:21:00 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20120215142100.27303.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 14:21:00

Modified files:
	tools          : dmsetup.c 

Log message:
	Fix segfault in dmsetup when using table specification with --table.
	
	Segfault introduced with the patch that added dm_free(_table) at the
	end of dmsetup (in this release).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/tools/dmsetup.c	2012/02/15 12:08:57	1.179
+++ LVM2/tools/dmsetup.c	2012/02/15 14:20:59	1.180
@@ -3654,7 +3654,11 @@
 			_switches[SHOWKEYS_ARG]++;
 		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
-			_table = optarg;
+			if (!(_table = dm_malloc(strlen(optarg + 1)))) {
+				log_error("Could not allocate memory for table string.");
+				return 0;
+			}
+			strcpy(_table, optarg);
 		}
 		if (ind == TREE_ARG)
 			_switches[TREE_ARG]++;


