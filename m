From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Oct 2006 16:37:55 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20061014163755.26096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-14 16:37:55

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Fall back to internal locking if external locking lib is missing or fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.469&r2=1.470
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2006/10/13 21:33:31	1.469
+++ LVM2/WHATS_NEW	2006/10/14 16:37:54	1.470
@@ -1,5 +1,6 @@
 Version 2.02.12 -
 ===================================
+  Fall back to internal locking if external locking lib is missing or fails.
   Retain activation state after changing LV minor number with --force.
   Propagate clustered flag in vgsplit and require resizeable flag.
 
--- LVM2/lib/locking/locking.c	2006/09/02 01:18:17	1.33
+++ LVM2/lib/locking/locking.c	2006/10/14 16:37:54	1.34
@@ -144,18 +144,18 @@
 	case 2:
 		if (!cmd->is_static) {
 			log_very_verbose("External locking selected.");
-			if (!init_external_locking(&_locking, cmd))
-				break;
-			return 1;
+			if (init_external_locking(&_locking, cmd))
+				return 1;
 		}
 		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
 					  DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))
 			break;
-		log_very_verbose("Falling back to clustered locking.");
-		/* Fall through */
 #endif
 
 #ifdef CLUSTER_LOCKING_INTERNAL
+		log_very_verbose("Falling back to internal clustered locking.");
+		/* Fall through */
+
 	case 3:
 		log_very_verbose("Cluster locking selected.");
 		if (!init_cluster_locking(&_locking, cmd))


