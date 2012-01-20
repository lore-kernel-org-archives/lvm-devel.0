From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 10:58:17 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20120120105817.2282.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 10:58:17

Modified files:
	tools          : dmsetup.c 

Log message:
	Tiny cleanup
	
	Just remove double braces from conditions when they are not really needed.
	(So it doesn't look like an assignment and comparison).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173

--- LVM2/tools/dmsetup.c	2012/01/18 18:52:02	1.172
+++ LVM2/tools/dmsetup.c	2012/01/20 10:58:17	1.173
@@ -3467,32 +3467,32 @@
 			/* FIXME Accept modes as per chmod */
 			_int_args[MODE_ARG] = (int) strtol(optarg, NULL, 8);
 		}
-		if ((ind == EXEC_ARG)) {
+		if (ind == EXEC_ARG) {
 			_switches[EXEC_ARG]++;
 			_command = optarg;
 		}
-		if ((ind == TARGET_ARG)) {
+		if (ind == TARGET_ARG) {
 			_switches[TARGET_ARG]++;
 			_target = optarg;
 		}
-		if ((ind == INACTIVE_ARG))
-			_switches[INACTIVE_ARG]++;
-		if ((ind == NAMEPREFIXES_ARG))
+		if (ind == INACTIVE_ARG)
+		       _switches[INACTIVE_ARG]++;
+		if (ind == NAMEPREFIXES_ARG)
 			_switches[NAMEPREFIXES_ARG]++;
-		if ((ind == NOFLUSH_ARG))
+		if (ind == NOFLUSH_ARG)
 			_switches[NOFLUSH_ARG]++;
-		if ((ind == NOHEADINGS_ARG))
+		if (ind == NOHEADINGS_ARG)
 			_switches[NOHEADINGS_ARG]++;
-		if ((ind == NOLOCKFS_ARG))
+		if (ind == NOLOCKFS_ARG)
 			_switches[NOLOCKFS_ARG]++;
-		if ((ind == NOOPENCOUNT_ARG))
+		if (ind == NOOPENCOUNT_ARG)
 			_switches[NOOPENCOUNT_ARG]++;
-		if ((ind == READAHEAD_ARG)) {
+		if (ind == READAHEAD_ARG) {
 			_switches[READAHEAD_ARG]++;
 			if (!strcasecmp(optarg, "auto"))
 				_int_args[READAHEAD_ARG] = DM_READ_AHEAD_AUTO;
 			else if (!strcasecmp(optarg, "none"))
-                		_int_args[READAHEAD_ARG] = DM_READ_AHEAD_NONE;
+				_int_args[READAHEAD_ARG] = DM_READ_AHEAD_NONE;
 			else {
 				for (s = optarg; isspace(*s); s++)
 					;
@@ -3507,23 +3507,23 @@
 				}
 			}
 		}
-		if ((ind == RETRY_ARG))
+		if (ind == RETRY_ARG)
 			_switches[RETRY_ARG]++;
-		if ((ind == ROWS_ARG))
+		if (ind == ROWS_ARG)
 			_switches[ROWS_ARG]++;
-		if ((ind == SETUUID_ARG))
+		if (ind == SETUUID_ARG)
 			_switches[SETUUID_ARG]++;
-		if ((ind == SHOWKEYS_ARG))
+		if (ind == SHOWKEYS_ARG)
 			_switches[SHOWKEYS_ARG]++;
-		if ((ind == TABLE_ARG)) {
+		if (ind == TABLE_ARG) {
 			_switches[TABLE_ARG]++;
 			_table = optarg;
 		}
-		if ((ind == TREE_ARG))
+		if (ind == TREE_ARG)
 			_switches[TREE_ARG]++;
-		if ((ind == UNQUOTED_ARG))
+		if (ind == UNQUOTED_ARG)
 			_switches[UNQUOTED_ARG]++;
-		if ((ind == VERSION_ARG))
+		if (ind == VERSION_ARG)
 			_switches[VERSION_ARG]++;
 	}
 


