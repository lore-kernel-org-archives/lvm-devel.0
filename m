From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Mar 2011 22:57:51 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-string.c
Message-ID: <20110313225751.12383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-13 22:57:51

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-string.c 

Log message:
	Fix buffer allocation size for uuid string
	
	We have 3 components and traling '\0' so allocate proper room for all of them.
	Problem was nicely hidden by allocation from pool and allocation aligment
	offset - so to trigger real problem with this one is actually hard.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1952&r2=1.1953
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2011/03/13 22:52:16	1.1952
+++ LVM2/WHATS_NEW	2011/03/13 22:57:51	1.1953
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix buffer allocation in build_dm_uuid().
   Fix readlink usage inside get_primary_dev().
   Use format instance mempool where possible and adequate.
   Call destroy_instance for any PVs found in VG structure during vg_free call.
--- LVM2/lib/misc/lvm-string.c	2010/11/17 10:19:30	1.24
+++ LVM2/lib/misc/lvm-string.c	2011/03/13 22:57:51	1.25
@@ -229,7 +229,7 @@
 	if (!layer)
 		layer = "";
 
-	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1;
+	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1 + 1;
 
 	if (!(dmuuid = dm_pool_alloc(mem, len))) {
 		log_error("build_dm_name: Allocation failed for %" PRIsize_t


