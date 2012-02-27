From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:26:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20120227112627.2962.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:26:26

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Nicer cleanup of excl_uuid hash
	
	Since it on exit path, it's not a big difference,
	but makes less noise in analyzer and valgrind.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2316&r2=1.2317
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2012/02/27 11:23:15	1.2316
+++ LVM2/WHATS_NEW	2012/02/27 11:26:25	1.2317
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Add missing cleanup of excl_uuid hash on some exit paths of clvmd.
   Check for existance of vg_name in _format1/_pool_vg_read().
   Fix missing break in _format_pvsegs (2.02.92).
   Test seg pointer for non-null it in raid_target_percent error path.
--- LVM2/daemons/clvmd/clvmd.c	2012/02/27 10:17:06	1.122
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/27 11:26:25	1.123
@@ -345,6 +345,7 @@
 	debug_t debug_arg = DEBUG_OFF;
 	int clusterwide_opt = 0;
 	mode_t old_mask;
+	int ret = 1;
 
 	struct option longopts[] = {
 		{ "help", 0, 0, 'h' },
@@ -372,7 +373,8 @@
 
 		case 'S':
 			check_permissions();
-			return restart_clvmd(clusterwide_opt)==1?0:1;
+			ret = (restart_clvmd(clusterwide_opt) == 1) ? 0 : 1;
+			goto out;
 
 		case 'C':
 			clusterwide_opt = 1;
@@ -402,7 +404,7 @@
 		case 'E':
 			if (!dm_hash_insert(lvm_params.excl_uuid, optarg, optarg)) {
 				fprintf(stderr, "Failed to allocate hash entry\n");
-				return 1;
+				goto out;
 			}
 			break;
 		case 'T':
@@ -624,9 +626,11 @@
 		free(delfd);
 	}
 
+	ret = 0;
+out:
 	dm_hash_destroy(lvm_params.excl_uuid);
 
-	return 0;
+	return ret;
 }
 
 /* Called when the cluster layer has completed initialisation.


