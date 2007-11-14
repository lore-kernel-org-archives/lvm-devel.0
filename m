From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2007 00:08:27 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c tools/lvc ...
Message-ID: <20071114000827.32710.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-14 00:08:25

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 
	tools          : lvconvert.c lvcreate.c lvmcmdline.c lvresize.c 
	                 pvcreate.c pvresize.c vgchange.c vgconvert.c 
	                 vgcreate.c 

Log message:
	Accept sizes with --readahead argument.
	Store size arguments as sectors internally.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.733&r2=1.734
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2007/11/12 20:51:53	1.733
+++ LVM2/WHATS_NEW	2007/11/14 00:08:24	1.734
@@ -1,5 +1,7 @@
 Version 2.02.29 -
 ==================================
+  Accept sizes with --readahead argument.
+  Store size arguments as sectors internally.
   Attempt to remove incomplete LVs with lvcreate zeroing/activation problems.
   Add read_ahead activation code.
   Add activation/readahead configuration option and FMT_RESTRICTED_READAHEAD.
--- LVM2/lib/report/report.c	2007/11/12 20:51:54	1.66
+++ LVM2/lib/report/report.c	2007/11/14 00:08:25	1.67
@@ -566,30 +566,27 @@
 			     const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	uint64_t size;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO) {
 		dm_report_field_set_value(field, "auto", &_minusone);
 		return 1;
 	}
 
-	size = (uint64_t) lv->read_ahead;
-
-	return _size64_disp(rh, mem, field, &size, private);
+	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
 
 static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data,
-			      void *private __attribute((unused)))
+			      void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (lv_info(lv->vg->cmd, lv, &info, 0, 1) && info.exists)
-		return dm_report_field_int(rh, field, &info.read_ahead);
+	if (!lv_info(lv->vg->cmd, lv, &info, 0, 1) || !info.exists)
+		return dm_report_field_uint64(rh, field, &_minusone);
 
-	return dm_report_field_uint64(rh, field, &_minusone);
+	return _size32_disp(rh, mem, field, &info.read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
--- LVM2/tools/lvconvert.c	2007/11/07 16:33:12	1.43
+++ LVM2/tools/lvconvert.c	2007/11/14 00:08:25	1.44
@@ -135,7 +135,7 @@
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
-		lp->chunk_size = 2 * arg_uint_value(cmd, chunksize_ARG, 8);
+		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
 			log_error("Chunk size must be a power of 2 in the "
@@ -175,8 +175,7 @@
 				log_error("Negative regionsize is invalid");
 				return 0;
 			}
-			lp->region_size = 2 * arg_uint_value(cmd,
-							     regionsize_ARG, 0);
+			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
 		} else {
 			region_size = 2 * find_config_tree_int(cmd,
 						"activation/mirror_region_size",
--- LVM2/tools/lvcreate.c	2007/11/12 21:50:21	1.158
+++ LVM2/tools/lvcreate.c	2007/11/14 00:08:25	1.159
@@ -173,7 +173,7 @@
 			log_error("Negative size is invalid");
 			return 0;
 		}
-		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0)) * 2;
+		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lp->percent = PERCENT_NONE;
 	}
 
@@ -195,7 +195,7 @@
 	if (lp->stripes > 1 && !lp->stripe_size) {
 		lp->stripe_size = find_config_tree_int(cmd,
 						  "metadata/stripesize",
-						  DEFAULT_STRIPESIZE) * 2;
+						  DEFAULT_STRIPESIZE);
 		log_print("Using default stripesize %s",
 			  display_size(cmd, (uint64_t) lp->stripe_size));
 	}
@@ -230,12 +230,12 @@
 			return 0;
 		}
 		/* Check to make sure we won't overflow lp->stripe_size */
-		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
+		if(arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
 			log_error("Stripe size cannot be larger than %s",
 				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 			return 0;
 		}
-		lp->stripe_size = 2 * arg_uint_value(cmd, stripesize_ARG, 0);
+		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 	}
 
 
@@ -310,7 +310,7 @@
 			log_error("Negative regionsize is invalid");
 			return 0;
 		}
-		lp->region_size = 2 * arg_uint_value(cmd, regionsize_ARG, 0);
+		lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
 	} else {
 		region_size = 2 * find_config_tree_int(cmd,
 					"activation/mirror_region_size",
@@ -375,7 +375,7 @@
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
-		lp->chunk_size = 2 * arg_uint_value(cmd, chunksize_ARG, 8);
+		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
 		    (lp->chunk_size & (lp->chunk_size - 1))) {
 			log_error("Chunk size must be a power of 2 in the "
--- LVM2/tools/lvmcmdline.c	2007/11/09 16:51:54	1.54
+++ LVM2/tools/lvmcmdline.c	2007/11/14 00:08:25	1.55
@@ -169,6 +169,7 @@
 	return 1;
 }
 
+/* Size stored in sectors */
 static int _size_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a, int factor)
 {
 	char *ptr;
@@ -211,6 +212,8 @@
 
 		while (i-- > 0)
 			v *= 1024;
+
+		v *= 2;
 	} else
 		v *= factor;
 
@@ -224,12 +227,12 @@
 
 int size_kb_arg(struct cmd_context *cmd, struct arg *a)
 {
-	return _size_arg(cmd, a, 1);
+	return _size_arg(cmd, a, 2);
 }
 
 int size_mb_arg(struct cmd_context *cmd, struct arg *a)
 {
-	return _size_arg(cmd, a, 1024);
+	return _size_arg(cmd, a, 2048);
 }
 
 int int_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
@@ -377,9 +380,6 @@
  */
 int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 {
-	if (int_arg(cmd, a))
-		return 1;
-
 	if (!strcasecmp(a->value, "auto")) {
 		a->ui_value = DM_READ_AHEAD_AUTO;
 		return 1;
@@ -390,7 +390,13 @@
 		return 1;
 	}
 
-	return 0;
+	if (!_size_arg(cmd, a, 1))
+		return 0;
+
+	if (a->sign == SIGN_MINUS)
+		return 0;
+
+	return 1;
 }
 
 static void __alloc(int size)
--- LVM2/tools/lvresize.c	2007/11/12 20:51:54	1.87
+++ LVM2/tools/lvresize.c	2007/11/14 00:08:25	1.88
@@ -55,7 +55,7 @@
 		return 0;
 	}
 
-	if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
+	if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
 		log_error("Stripe size cannot be larger than %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
@@ -63,16 +63,15 @@
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size) {
+	else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size * 2) {
 		log_error("Reducing stripe size %s to maximum, "
 			  "physical extent size %s",
 			  display_size(cmd,
-				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0) * 2),
+				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0)),
 			  display_size(cmd, (uint64_t) vg->extent_size));
 		lp->stripe_size = vg->extent_size;
 	} else
-		lp->stripe_size = 2 * arg_uint_value(cmd,
-						     stripesize_ARG, 0);
+		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 
 	if (lp->mirrors) {
 		log_error("Mirrors and striping cannot be combined yet.");
@@ -208,7 +207,7 @@
 
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, size_ARG)) {
-		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0)) * 2;
+		lp->size = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
 		lp->sign = arg_sign_value(cmd, size_ARG, SIGN_NONE);
 		lp->percent = PERCENT_NONE;
 	}
--- LVM2/tools/pvcreate.c	2007/11/02 20:40:05	1.56
+++ LVM2/tools/pvcreate.c	2007/11/14 00:08:25	1.57
@@ -186,14 +186,13 @@
 		log_error("Physical volume size may not be negative");
 		goto error;
 	}
-	size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0)) * 2;
+	size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
 	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
 		log_error("Metadata size may not be negative");
 		goto error;
 	}
-	pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0))
-	    * 2;
+	pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
 	if (!pvmetadatasize)
 		pvmetadatasize = find_config_tree_int(cmd,
 						 "metadata/pvmetadatasize",
--- LVM2/tools/pvresize.c	2007/08/30 20:30:41	1.15
+++ LVM2/tools/pvresize.c	2007/11/14 00:08:25	1.16
@@ -56,7 +56,7 @@
 	}
 
 	params.new_size = arg_uint64_value(cmd, physicalvolumesize_ARG,
-					   UINT64_C(0)) * 2;
+					   UINT64_C(0));
 
 	params.done = 0;
 	params.total = 0;
--- LVM2/tools/vgchange.c	2007/11/12 20:51:54	1.61
+++ LVM2/tools/vgchange.c	2007/11/14 00:08:25	1.62
@@ -388,7 +388,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0) * 2;
+	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
 	if (!extent_size) {
 		log_error("Physical extent size may not be zero");
 		return EINVALID_CMD_LINE;
--- LVM2/tools/vgconvert.c	2007/11/12 20:51:54	1.26
+++ LVM2/tools/vgconvert.c	2007/11/14 00:08:25	1.27
@@ -61,7 +61,7 @@
 		}
 
 		pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG,
-						  UINT64_C(0)) * 2;
+						  UINT64_C(0));
 		if (!pvmetadatasize)
 			pvmetadatasize =
 			    find_config_tree_int(cmd,
--- LVM2/tools/vgcreate.c	2007/11/02 20:40:05	1.51
+++ LVM2/tools/vgcreate.c	2007/11/14 00:08:25	1.52
@@ -77,7 +77,7 @@
 
 	/* Units of 512-byte sectors */
 	extent_size =
-	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_EXTENT) * 2;
+	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_EXTENT);
 
 	if (!extent_size) {
 		log_error("Physical extent size may not be zero");


