From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2012 14:27:54 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20120215142754.1634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-15 14:27:53

Modified files:
	tools          : dmsetup.c 

Log message:
	Simplify with dm_strdup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/tools/dmsetup.c	2012/02/15 14:20:59	1.180
+++ LVM2/tools/dmsetup.c	2012/02/15 14:27:53	1.181
@@ -3654,11 +3654,10 @@
 			_switches[SHOWKEYS_ARG]++;
 		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
-			if (!(_table = dm_malloc(strlen(optarg + 1)))) {
+			if (!(_table = dm_strdup(optarg))) {
 				log_error("Could not allocate memory for table string.");
 				return 0;
 			}
-			strcpy(_table, optarg);
 		}
 		if (ind == TREE_ARG)
 			_switches[TREE_ARG]++;


