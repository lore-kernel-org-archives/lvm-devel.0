From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2012 14:19:15 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h tools/l ...
Message-ID: <20120305141915.15507.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-05 14:19:14

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	tools          : lvcreate.c 

Log message:
	Fit thin pool metadata into 128MB
	
	If the lvcreate may decide some automagical values for a user,
	try to keep the pool metadata size into 128MB range for optimal
	perfomance (as suggested by Joe).
	
	So if the pool metadata size and chunk_size were not specified,
	try to select such values they would fit into 128MB size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2343&r2=1.2344
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.260&r2=1.261

--- LVM2/WHATS_NEW	2012/03/05 14:15:50	1.2343
+++ LVM2/WHATS_NEW	2012/03/05 14:19:13	1.2344
@@ -1,5 +1,6 @@
 Version 2.02.95 -
 ================================
+  Try to fit thin pool metadata size into 128MB.
   Print just warning on thin pool check callback path for failing check.
   Use 64bit math for verification of thin pool and snapshot chunk size.
   Validate udev structures in _insert_udev_dir().
--- LVM2/lib/config/defaults.h	2012/03/02 21:49:44	1.97
+++ LVM2/lib/config/defaults.h	2012/03/05 14:19:14	1.98
@@ -68,6 +68,7 @@
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
+#define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
 
 #define DEFAULT_UMASK 0077
 
--- LVM2/tools/lvcreate.c	2012/03/02 20:18:25	1.260
+++ LVM2/tools/lvcreate.c	2012/03/05 14:19:14	1.261
@@ -235,6 +235,7 @@
 {
 	uint32_t pv_extent_count;
 	struct logical_volume *origin = NULL;
+	int changed = 0;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -294,11 +295,26 @@
 	}
 
 	if (lp->create_thin_pool) {
-		if (!arg_count(vg->cmd, poolmetadatasize_ARG))
+		if (!arg_count(vg->cmd, poolmetadatasize_ARG)) {
 			/* Defaults to nr_pool_blocks * 64b */
 			lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
 				(uint64_t) (lp->chunk_size * (SECTOR_SIZE / UINT64_C(64)));
 
+			/* Check if we could eventually use bigger chunk size */
+			if (!arg_count(vg->cmd, chunksize_ARG)) {
+				while ((lp->poolmetadatasize >
+					(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+				       (lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+					lp->chunk_size <<= 1;
+					lp->poolmetadatasize >>= 1;
+					changed++;
+				}
+				if (changed)
+					log_verbose("Changed chunksize to %u sectors.",
+						    lp->chunk_size);
+			}
+		}
+
 		if (lp->poolmetadatasize > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
 			if (arg_count(vg->cmd, poolmetadatasize_ARG))
 				log_warn("WARNING: Maximum supported pool metadata size is 16GB.");


