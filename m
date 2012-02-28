From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 14:25:01 -0000
Subject: LVM2 lib/activate/dev_manager.c libdm/libdm-co ...
Message-ID: <20120228142501.29058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 14:24:59

Modified files:
	lib/activate   : dev_manager.c 
	libdm          : libdm-common.c 
	tools          : dmsetup.c lvchange.c lvconvert.c lvcreate.c 
	                 lvresize.c polldaemon.c pvcreate.c pvmove.c 
	                 pvresize.c toollib.c vgchange.c vgconvert.c 

Log message:
	Using enum types for enums
	
	alloc_policy_t, dm_string_mangling_t, percent_range_t, sign_t

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.271&r2=1.272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.256&r2=1.257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/lib/activate/dev_manager.c	2012/02/13 17:59:21	1.271
+++ LVM2/lib/activate/dev_manager.c	2012/02/28 14:24:57	1.272
@@ -494,7 +494,7 @@
 	if (a == PERCENT_0 && b == PERCENT_0)
 		return PERCENT_0;
 
-	return make_percent(numerator, denominator);
+	return (percent_range_t) make_percent(numerator, denominator);
 }
 
 static int _percent_run(struct dev_manager *dm, const char *name,
--- LVM2/libdm/libdm-common.c	2012/02/28 08:36:51	1.142
+++ LVM2/libdm/libdm-common.c	2012/02/28 14:24:57	1.143
@@ -68,7 +68,7 @@
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
-static int _name_mangling_mode = -1;
+static dm_string_mangling_t _name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
 
 #ifdef HAVE_SELINUX_LABEL_H
 static struct selabel_handle *_selabel_handle = NULL;
--- LVM2/tools/dmsetup.c	2012/02/27 11:28:48	1.182
+++ LVM2/tools/dmsetup.c	2012/02/28 14:24:57	1.183
@@ -3614,7 +3614,7 @@
 				log_error("Unknown name mangling mode");
 				return 0;
 			}
-			dm_set_name_mangling_mode(_int_args[MANGLENAME_ARG]);
+			dm_set_name_mangling_mode((dm_string_mangling_t) _int_args[MANGLENAME_ARG]);
 		}
 		if (ind == NAMEPREFIXES_ARG)
 			_switches[NAMEPREFIXES_ARG]++;
--- LVM2/tools/lvchange.c	2012/02/15 15:18:44	1.138
+++ LVM2/tools/lvchange.c	2012/02/28 14:24:58	1.139
@@ -340,7 +340,7 @@
 
 	want_contiguous = strcmp(arg_str_value(cmd, contiguous_ARG, "n"), "n");
 	alloc = want_contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
-	alloc = arg_uint_value(cmd, alloc_ARG, alloc);
+	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, alloc);
 
 	if (alloc == lv->alloc) {
 		log_error("Allocation policy of logical volume \"%s\" is "
--- LVM2/tools/lvconvert.c	2012/02/23 22:36:56	1.186
+++ LVM2/tools/lvconvert.c	2012/02/28 14:24:58	1.187
@@ -200,7 +200,7 @@
 		 * versus an additional qualifying argument being added here.
 		 */
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0);
-		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
+		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
 	}
 
 	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
@@ -229,7 +229,7 @@
 			return 0;
 		}
 
-		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
@@ -288,7 +288,7 @@
 	 	 */
 
 		if (arg_count(cmd, regionsize_ARG)) {
-			if (arg_sign_value(cmd, regionsize_ARG, 0) ==
+			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
 				    SIGN_MINUS) {
 				log_error("Negative regionsize is invalid");
 				return 0;
--- LVM2/tools/lvcreate.c	2012/02/27 10:00:23	1.256
+++ LVM2/tools/lvcreate.c	2012/02/28 14:24:58	1.257
@@ -321,7 +321,7 @@
 	}
 
 	if (arg_count(cmd, extents_ARG)) {
-		if (arg_sign_value(cmd, extents_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, extents_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative number of extents is invalid");
 			return 0;
 		}
@@ -331,7 +331,7 @@
 
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, size_ARG)) {
-		if (arg_sign_value(cmd, size_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, size_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative size is invalid");
 			return 0;
 		}
@@ -348,7 +348,7 @@
 			log_error("--poolmetadatasize may only be specified when allocating the thin pool.");
 			return 0;
 		}
-		if (arg_sign_value(cmd, poolmetadatasize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative poolmetadatasize is invalid.");
 			return 0;
 		}
@@ -361,7 +361,7 @@
 			log_error("Virtual size in incompatible with thin_pool segment type.");
 			return 0;
 		}
-		if (arg_sign_value(cmd, virtualsize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, virtualsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative virtual origin size is invalid");
 			return 0;
 		}
@@ -443,7 +443,7 @@
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (arg_count(cmd, regionsize_ARG)) {
-		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative regionsize is invalid");
 			return 0;
 		}
@@ -542,7 +542,8 @@
 {
 	unsigned pagesize;
 
-	lp->activate = arg_uint_value(cmd, available_ARG, CHANGE_AY);
+	lp->activate = (activation_change_t)
+		arg_uint_value(cmd, available_ARG, CHANGE_AY);
 
 	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
 		if (lp->zero && !seg_is_thin(lp)) {
@@ -688,7 +689,7 @@
 			}
 			log_print("Redundant mirrors argument: default is 0");
 		}
-		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
 			return 0;
 		}
@@ -743,7 +744,7 @@
 		if (arg_count(cmd, chunksize_ARG))
 			log_warn("WARNING: Ignoring --chunksize when using an existing pool.");
 	} else if (lp->snapshot || lp->create_thin_pool) {
-		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, chunksize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative chunk size is invalid");
 			return 0;
 		}
@@ -796,7 +797,7 @@
 
 	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
 
-	lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
+	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lp->alloc);
 
 	if (contiguous && (lp->alloc != ALLOC_CONTIGUOUS)) {
 		log_error("Conflicting contiguous and alloc arguments");
--- LVM2/tools/lvresize.c	2012/02/08 10:56:18	1.149
+++ LVM2/tools/lvresize.c	2012/02/28 14:24:58	1.150
@@ -50,7 +50,7 @@
 				const struct volume_group *vg,
 				struct lvresize_params *lp)
 {
-	if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Stripesize may not be negative.");
 		return 0;
 	}
@@ -415,7 +415,7 @@
 			lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
 		else
 			log_warn("Mirrors not supported. Ignoring.");
-		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
 			return EINVALID_CMD_LINE;
 		}
@@ -452,7 +452,7 @@
 		return ECMD_FAILED;
 	}
 
-	alloc = arg_uint_value(cmd, alloc_ARG, lv->alloc);
+	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lv->alloc);
 
 	if (lp->size) {
 		if (lp->size % vg->extent_size) {
--- LVM2/tools/polldaemon.c	2012/02/28 10:06:54	1.47
+++ LVM2/tools/polldaemon.c	2012/02/28 14:24:58	1.48
@@ -310,7 +310,7 @@
 
 	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
-	interval_sign = arg_sign_value(cmd, interval_ARG, 0);
+	interval_sign = arg_sign_value(cmd, interval_ARG, SIGN_NONE);
 	if (interval_sign == SIGN_MINUS)
 		log_error("Argument to --interval cannot be negative");
 	parms.interval = arg_uint_value(cmd, interval_ARG,
--- LVM2/tools/pvcreate.c	2012/02/23 13:11:10	1.99
+++ LVM2/tools/pvcreate.c	2012/02/28 14:24:58	1.100
@@ -78,7 +78,7 @@
 		release_vg(vg);
 	}
 
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
 		return 0;
 	}
--- LVM2/tools/pvmove.c	2011/12/08 18:06:33	1.92
+++ LVM2/tools/pvmove.c	2012/02/28 14:24:58	1.93
@@ -492,7 +492,7 @@
 						  &pv_name_arg, 0)))
 			goto_out;
 
-		alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+		alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 		if (alloc == ALLOC_INHERIT)
 			alloc = vg->alloc;
 
--- LVM2/tools/pvresize.c	2011/08/10 20:25:31	1.46
+++ LVM2/tools/pvresize.c	2012/02/28 14:24:59	1.47
@@ -162,7 +162,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
 		return 0;
 	}
--- LVM2/tools/toollib.c	2012/02/23 13:11:10	1.242
+++ LVM2/tools/toollib.c	2012/02/28 14:24:59	1.243
@@ -1257,7 +1257,7 @@
 		/* Default depends on current locking type */
 		vp_new->clustered = locking_is_clustered();
 
-	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return 1;
 	}
@@ -1268,12 +1268,12 @@
 		return 1;
 	}
 
-	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Max Logical Volumes may not be negative");
 		return 1;
 	}
 
-	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Max Physical Volumes may not be negative");
 		return 1;
 	}
@@ -1435,7 +1435,7 @@
 	if (arg_count(cmd, zero_ARG))
 		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 
-	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, dataalignment_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume data alignment may not be negative");
 		return 0;
 	}
@@ -1454,7 +1454,7 @@
 		pp->data_alignment = 0;
 	}
 
-	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, dataalignmentoffset_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume data alignment offset may not be negative");
 		return 0;
 	}
@@ -1472,7 +1472,7 @@
 		pp->data_alignment_offset = 0;
 	}
 
-	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Metadata size may not be negative");
 		return 0;
 	}
@@ -1562,7 +1562,7 @@
 
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 	if (*stripe_size) {
-		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative stripesize is invalid");
 			return 0;
 		}
--- LVM2/tools/vgchange.c	2012/02/15 15:18:44	1.130
+++ LVM2/tools/vgchange.c	2012/02/28 14:24:59	1.131
@@ -280,7 +280,7 @@
 {
 	alloc_policy_t alloc;
 
-	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
+	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
 	/* FIXME: make consistent with vg_set_alloc_policy() */
 	if (alloc == vg->alloc) {
@@ -596,13 +596,13 @@
 	}
 
 	if (arg_count(cmd, maxphysicalvolumes_ARG) &&
-	    arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
+	    arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("MaxPhysicalVolumes may not be negative");
 		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, physicalextentsize_ARG) &&
-	    arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
+	    arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
 	}
--- LVM2/tools/vgconvert.c	2012/02/13 11:04:00	1.52
+++ LVM2/tools/vgconvert.c	2012/02/28 14:24:59	1.53
@@ -42,7 +42,7 @@
 	}
 
 	if (cmd->fmt->features & FMT_MDAS) {
-		if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
+		if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Metadata size may not be negative");
 			return EINVALID_CMD_LINE;
 		}


