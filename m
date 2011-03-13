From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Mar 2011 23:18:31 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c
Message-ID: <20110313231831.20022.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-13 23:18:30

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c 

Log message:
	Revert this commit
	
	This buffer allocation must have been problem somewhere else.
	(as sizeof() already has the 'extra' '\0' included).
	For now reverting this commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1954&r2=1.1955
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2011/03/13 23:05:48	1.1954
+++ LVM2/WHATS_NEW	2011/03/13 23:18:30	1.1955
@@ -1,7 +1,6 @@
 Version 2.02.85 - 
 ===================================
   Fix allocation of system_id buffer in volume_group structure.
-  Fix buffer allocation in build_dm_uuid().
   Fix readlink usage inside get_primary_dev().
   Use format instance mempool where possible and adequate.
   Call destroy_instance for any PVs found in VG structure during vg_free call.
--- LVM2/lib/misc/lvm-string.c	2011/03/13 22:57:51	1.25
+++ LVM2/lib/misc/lvm-string.c	2011/03/13 23:18:30	1.26
@@ -229,7 +229,7 @@
 	if (!layer)
 		layer = "";
 
-	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1 + 1;
+	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1;
 
 	if (!(dmuuid = dm_pool_alloc(mem, len))) {
 		log_error("build_dm_name: Allocation failed for %" PRIsize_t


