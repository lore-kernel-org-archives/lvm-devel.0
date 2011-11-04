From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2011 22:43:19 -0000
Subject: LVM2 lib/config/defaults.h lib/metadata/lv_man ...
Message-ID: <20111104224319.32754.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-04 22:43:12

Modified files:
	lib/config     : defaults.h 
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : args.h commands.h lvcreate.c 

Log message:
	Thin supports poolmetadatasize setting
	
	Add option to set pool metadatasize.
	For passing size parameter reuse region_size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.320&r2=1.321
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.221&r2=1.222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.244&r2=1.245

--- LVM2/lib/config/defaults.h	2011/10/11 09:13:39	1.85
+++ LVM2/lib/config/defaults.h	2011/11/04 22:43:10	1.86
@@ -60,6 +60,9 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
+#define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
+
 #define DEFAULT_UMASK 0077
 
 #ifdef LVM1_FALLBACK
--- LVM2/lib/metadata/lv_manip.c	2011/11/04 01:31:23	1.320
+++ LVM2/lib/metadata/lv_manip.c	2011/11/04 22:43:10	1.321
@@ -810,8 +810,9 @@
 		}
 	} else if (segtype_is_thin_pool(segtype)) {
 		ah->log_area_count = metadata_area_count;
-// FIXME Calculate thin metadata area size (--metadatasize, or reuse --regionsize??)
-		ah->log_len = 128 * 1024 * 1024 / (512 * extent_size); /* Fixed 128MB */
+		/* thin_pool uses region_size to pass metadata size in extents */
+		ah->log_len = ah->region_size;
+		ah->region_size = 0;
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -4161,7 +4162,8 @@
 
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
-		       lp->mirrors, lp->region_size,
+		       lp->mirrors,
+		       seg_is_thin_pool(lp) ? lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
 		       seg_is_thin_volume(lp) ? lp->pool : NULL, lp->pvh, lp->alloc))
 		return_NULL;
--- LVM2/lib/metadata/metadata-exported.h	2011/11/03 14:57:04	1.221
+++ LVM2/lib/metadata/metadata-exported.h	2011/11/04 22:43:10	1.222
@@ -603,6 +603,8 @@
 	uint32_t extents; /* all */
 	uint32_t voriginextents; /* snapshot */
 	uint64_t voriginsize; /* snapshot */
+	uint32_t poolmetadataextents; /* thin pool */
+	uint64_t poolmetadatasize; /* thin pool */
 	struct dm_list *pvh; /* all */
 
 	uint32_t permission; /* all */
--- LVM2/tools/args.h	2011/09/06 00:26:43	1.84
+++ LVM2/tools/args.h	2011/11/04 22:43:11	1.85
@@ -69,6 +69,7 @@
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
--- LVM2/tools/commands.h	2011/10/18 16:27:45	1.165
+++ LVM2/tools/commands.h	2011/11/04 22:43:11	1.166
@@ -192,6 +192,7 @@
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
+   "\t[--poolmetadatasize Size[bBsSkKmMgG]]\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
@@ -210,7 +211,7 @@
    noudevsync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, thin_ARG, thinpool_ARG, type_ARG, virtualoriginsize_ARG,
-   virtualsize_ARG, zero_ARG)
+   poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/lvcreate.c	2011/10/21 09:55:07	1.244
+++ LVM2/tools/lvcreate.c	2011/11/04 22:43:11	1.245
@@ -283,6 +283,17 @@
 		case PERCENT_NONE:
 			break;
 	}
+
+	if (lp->create_thin_pool && !lp->poolmetadatasize)
+		/* Defaults to nr_pool_blocks * 64b */
+		lp->poolmetadatasize =  (uint64_t) lp->extents * vg->extent_size /
+			(uint64_t) lp->chunk_size * UINT64_C(64);
+
+	if (lp->poolmetadatasize &&
+	    !(lp->poolmetadataextents = extents_from_size(vg->cmd, lp->poolmetadatasize,
+							  vg->extent_size)))
+		return_0;
+
 	return 1;
 }
 
@@ -323,6 +334,18 @@
 	if (lp->thin && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
 		lp->create_thin_pool = 1;
 
+	if (arg_count(cmd, poolmetadatasize_ARG)) {
+		if (!seg_is_thin(lp)) {
+			log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
+			return 0;
+		}
+		if (arg_sign_value(cmd, poolmetadatasize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative poolmetadatasize is invalid.");
+			return 0;
+		}
+		lp->poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+	}
+
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, virtualsize_ARG)) {
 		if (seg_is_thin_pool(lp)) {
@@ -478,6 +501,33 @@
 	return 1;
 }
 
+static int _read_thin_params(struct lvcreate_params *lp,
+			     struct cmd_context *cmd)
+{
+	if (!seg_is_thin(lp)) {
+		if (lp->poolmetadatasize) {
+			log_error("Pool metadata size option is only for pool creation.");
+			return 0;
+		}
+		return 1;
+	}
+
+	if (lp->create_thin_pool) {
+		if (lp->poolmetadatasize > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+			log_warn("WARNING: Maximum supported pool metadata size is 16GB.");
+			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+		} else if (lp->poolmetadatasize < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE))
+			lp->poolmetadatasize = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+		log_verbose("Setting pool metadata size to %" PRIu64 " sectors.",
+			    lp->poolmetadatasize);
+	} else if (lp->poolmetadatasize) {
+		log_error("Pool metadata size options is only for pool creation.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd)
 {
 	unsigned pagesize;
@@ -677,7 +727,8 @@
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    !_read_mirror_params(lp, cmd) ||
-	    !_read_raid_params(lp, cmd))
+	    !_read_raid_params(lp, cmd) ||
+	    !_read_thin_params(lp, cmd))
 		return_0;
 
 	if (lp->snapshot && lp->thin && arg_count(cmd, chunksize_ARG))
@@ -796,6 +847,11 @@
 			return 0;
 		}
 
+		if (arg_count(vg->cmd, poolmetadatasize_ARG)) {
+			log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
+			return 0;
+		}
+
 		if (arg_count(vg->cmd, stripesize_ARG)) {
 			log_error("--stripesize may only be specified when allocating the thin pool.");
 			return 0;


