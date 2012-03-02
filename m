From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 20:18:27 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20120302201827.1578.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 20:18:25

Modified files:
	tools          : lvcreate.c 

Log message:
	Merge metadata size checking
	
	Move the code for poolmetadatasize operation into one place.
	Report override for minimum and maximum size.
	Drop _read_thin_params function its error reporting is handled elsewhere.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.259&r2=1.260

--- LVM2/tools/lvcreate.c	2012/03/02 17:25:21	1.259
+++ LVM2/tools/lvcreate.c	2012/03/02 20:18:25	1.260
@@ -293,15 +293,29 @@
 			break;
 	}
 
-	if (lp->create_thin_pool && !arg_count(vg->cmd, poolmetadatasize_ARG))
-		/* Defaults to nr_pool_blocks * 64b */
-		lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
-			(uint64_t) (lp->chunk_size * (SECTOR_SIZE / UINT64_C(64)));
-
-	if (lp->poolmetadatasize &&
-	    !(lp->poolmetadataextents = extents_from_size(vg->cmd, lp->poolmetadatasize,
-							  vg->extent_size)))
-		return_0;
+	if (lp->create_thin_pool) {
+		if (!arg_count(vg->cmd, poolmetadatasize_ARG))
+			/* Defaults to nr_pool_blocks * 64b */
+			lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
+				(uint64_t) (lp->chunk_size * (SECTOR_SIZE / UINT64_C(64)));
+
+		if (lp->poolmetadatasize > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+			if (arg_count(vg->cmd, poolmetadatasize_ARG))
+				log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
+			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+		} else if (lp->poolmetadatasize < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+			if (arg_count(vg->cmd, poolmetadatasize_ARG))
+				log_warn("WARNING: Minimum supported pool metadata size is 2M.");
+			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+		}
+
+		log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
+			    lp->poolmetadatasize);
+
+		if (!(lp->poolmetadataextents =
+		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
+			return_0;
+	}
 
 	return 1;
 }
@@ -511,33 +525,6 @@
 	return 1;
 }
 
-static int _read_thin_params(struct lvcreate_params *lp,
-			     struct cmd_context *cmd)
-{
-	if (!seg_is_thin(lp)) {
-		if (lp->poolmetadatasize) {
-			log_error("Pool metadata size option is only for pool creation.");
-			return 0;
-		}
-		return 1;
-	}
-
-	if (lp->create_thin_pool) {
-		if (lp->poolmetadatasize > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-			log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
-			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
-		} else if (lp->poolmetadatasize < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE))
-			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
-		log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
-			    lp->poolmetadatasize);
-	} else if (lp->poolmetadatasize) {
-		log_error("Pool metadata size options is only for pool creation.");
-		return 0;
-	}
-
-	return 1;
-}
-
 static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd)
 {
 	unsigned pagesize;
@@ -737,8 +724,7 @@
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    !_read_mirror_params(lp, cmd) ||
-	    !_read_raid_params(lp, cmd) ||
-	    !_read_thin_params(lp, cmd))
+	    !_read_raid_params(lp, cmd))
 		return_0;
 
 	if (lp->snapshot && lp->thin && arg_count(cmd, chunksize_ARG))


