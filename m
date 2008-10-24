From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2008 01:16:17 -0000
Subject: LVM2 lib/locking/locking.c ./WHATS_NEW
Message-ID: <20081024011617.13624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-24 01:16:17

Modified files:
	lib/locking    : locking.c 
	.              : WHATS_NEW 

Log message:
	Accept locking fallback_to_* options in the global section as documented.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.980&r2=1.981

--- LVM2/lib/locking/locking.c	2008/09/10 10:14:59	1.50
+++ LVM2/lib/locking/locking.c	2008/10/24 01:16:16	1.51
@@ -233,7 +233,8 @@
 				return 1;
 		}
 		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
-					  DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))
+			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
+						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING)))
 			break;
 #endif
 
@@ -255,7 +256,8 @@
 
 	if ((type == 2 || type == 3) &&
 	    find_config_tree_int(cmd, "locking/fallback_to_local_locking",
-				 DEFAULT_FALLBACK_TO_LOCAL_LOCKING)) {
+	    	    find_config_tree_int(cmd, "global/fallback_to_local_locking",
+					 DEFAULT_FALLBACK_TO_LOCAL_LOCKING))) {
 		log_warn("WARNING: Falling back to local file-based locking.");
 		log_warn("Volume Groups with the clustered attribute will "
 			  "be inaccessible.");
--- LVM2/WHATS_NEW	2008/10/23 11:21:04	1.980
+++ LVM2/WHATS_NEW	2008/10/24 01:16:16	1.981
@@ -1,5 +1,6 @@
 Version 2.02.42 - 
 ===================================
+  Accept locking fallback_to_* options in the global section as documented.
   Fix temp table activation in mirror conversions not to happen in other cmds.
   Fix temp table in mirror conversions to use always-present error not zero.
 


