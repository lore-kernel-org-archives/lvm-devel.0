From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Sep 2007 21:08:16 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20070906210816.21939.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-06 21:08:16

Modified files:
	tools          : lvresize.c 

Log message:
	Fixup _lvresize error return codes and modularize function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/tools/lvresize.c	2007/08/20 20:55:30	1.80
+++ LVM2/tools/lvresize.c	2007/09/06 21:08:16	1.81
@@ -46,6 +46,128 @@
 	char **argv;
 };
 
+static int validate_stripesize(struct cmd_context *cmd,
+			       struct volume_group *vg,
+			       struct lvresize_params *lp)
+{
+	if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
+		log_error("Stripesize may not be negative.");
+		return 0;
+	}
+
+	if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
+		log_error("Stripe size cannot be larger than %s",
+			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
+		log_warn("Varied stripesize not supported. Ignoring.");
+	else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size) {
+		log_error("Reducing stripe size %s to maximum, "
+			  "physical extent size %s",
+			  display_size(cmd,
+				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0) * 2),
+			  display_size(cmd, (uint64_t) vg->extent_size));
+		lp->stripe_size = vg->extent_size;
+	} else
+		lp->stripe_size = 2 * arg_uint_value(cmd,
+						     stripesize_ARG, 0);
+
+	if (lp->mirrors) {
+		log_error("Mirrors and striping cannot be combined yet.");
+		return 0;
+	}
+	if (lp->stripe_size & (lp->stripe_size - 1)) {
+		log_error("Stripe size must be power of 2");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int confirm_resizefs_reduce(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   struct logical_volume *lv,
+				   struct lvresize_params *lp)
+{
+	struct lvinfo info;
+
+	memset(&info, 0, sizeof(info));
+
+	if (!lv_info(cmd, lv, &info, 1) && driver_version(NULL, 0)) {
+		log_error("lv_info failed: aborting");
+		return 0;
+	}
+
+	if (lp->resizefs && !info.exists) {
+		log_error("Logical volume %s must be activated "
+			  "before resizing filesystem", lp->lv_name);
+		return 0;
+	}
+
+	if (info.exists && !lp->resizefs && (lp->resize == LV_REDUCE)) {
+		log_warn("WARNING: Reducing active%s logical volume "
+			 "to %s", info.open_count ? " and open" : "",
+			 display_size(cmd, (uint64_t) lp->extents *
+				      vg->extent_size));
+
+		log_warn("THIS MAY DESTROY YOUR DATA "
+			 "(filesystem etc.)");
+
+		if (!arg_count(cmd, force_ARG)) {
+			if (yes_no_prompt("Do you really want to "
+					  "reduce %s? [y/n]: ",
+					  lp->lv_name) == 'n') {
+				log_print("Logical volume %s NOT "
+					  "reduced", lp->lv_name);
+				return 0;
+			}
+			if (sigint_caught())
+				return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int do_resizefs_reduce(struct cmd_context *cmd, struct volume_group *vg,
+			      struct logical_volume *lv,
+			      struct lvresize_params *lp)
+{
+	char lv_path[PATH_MAX];
+	char size_buf[SIZE_BUF];
+
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+			lp->vg_name, lp->lv_name) < 0) {
+		log_error("Couldn't create LV path for %s",
+			  lp->lv_name);
+		return 0;
+	}
+
+	if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64,
+			(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
+		log_error("Couldn't generate new LV size string");
+		return 0;
+	}
+
+	if (!lp->nofsck) {
+		if (!exec_cmd("fsadm", "check", lv_path, NULL)) {
+			stack;
+			return 0;
+		}
+	}
+
+	if (lp->resize == LV_REDUCE) {
+		if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
+			stack;
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			    struct lvresize_params *lp)
 {
@@ -165,43 +287,13 @@
 			log_warn("Mirrors not supported. Ignoring.");
 		if (arg_sign_value(cmd, mirrors_ARG, 0) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
-			return 0;
+			return EINVALID_CMD_LINE;
 		}
 	}
 
 	if (arg_count(cmd, stripesize_ARG)) {
-		if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
-			log_error("Stripesize may not be negative.");
-			return ECMD_FAILED;
-		}
-
-		if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT) {
-			log_error("Stripe size cannot be larger than %s",
-				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
-			return 0;
-		}
-
-		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-			log_warn("Varied stripesize not supported. Ignoring.");
-		else if (arg_uint_value(cmd, stripesize_ARG, 0) > vg->extent_size) {
-                	log_error("Reducing stripe size %s to maximum, "
-				  "physical extent size %s",
-				  display_size(cmd,
-					(uint64_t) arg_uint_value(cmd, stripesize_ARG, 0) * 2),
-	                          display_size(cmd, (uint64_t) vg->extent_size));
-                	lp->stripe_size = vg->extent_size;
-        	} else
-			lp->stripe_size = 2 * arg_uint_value(cmd,
-							     stripesize_ARG, 0);
-
-		if (lp->mirrors) {
-			log_error("Mirrors and striping cannot be combined yet.");
-			return ECMD_FAILED;
-		}
-		if (lp->stripe_size & (lp->stripe_size - 1)) {
-			log_error("Stripe size must be power of 2");
-			return 0;
-		}
+		if (!validate_stripesize(cmd, vg, lp))
+			return EINVALID_CMD_LINE;
 	}
 
 	lv = lvl->lv;
@@ -393,7 +485,7 @@
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
 			log_error("Invalid stripe size %s",
 				  display_size(cmd, (uint64_t) lp->stripe_size));
-			return 0;
+			return EINVALID_CMD_LINE;
 		}
 	}
 
@@ -455,70 +547,13 @@
 	}
 
 	if (lp->resize == LV_REDUCE || lp->resizefs) {
-		memset(&info, 0, sizeof(info));
-
-		if (!lv_info(cmd, lv, &info, 1) && driver_version(NULL, 0)) {
-			log_error("lv_info failed: aborting");
-			return ECMD_FAILED;
-		}
-
-		if (lp->resizefs && !info.exists) {
-			log_error("Logical volume %s must be activated "
-				  "before resizing filesystem", lp->lv_name);
+		if (!confirm_resizefs_reduce(cmd, vg, lv, lp))
 			return ECMD_FAILED;
-		}
-
-		if (info.exists && !lp->resizefs && (lp->resize == LV_REDUCE)) {
-			log_warn("WARNING: Reducing active%s logical volume "
-				  "to %s", info.open_count ? " and open" : "",
-				  display_size(cmd, (uint64_t) lp->extents *
-						    vg->extent_size));
-
-			log_warn("THIS MAY DESTROY YOUR DATA "
-				 "(filesystem etc.)");
-
-			if (!arg_count(cmd, force_ARG)) {
-				if (yes_no_prompt("Do you really want to "
-						  "reduce %s? [y/n]: ",
-						  lp->lv_name) == 'n') {
-					log_print("Logical volume %s NOT "
-						  "reduced", lp->lv_name);
-					return ECMD_FAILED;
-				}
-				if (sigint_caught())
-					return ECMD_FAILED;
-			}
-		}
 	}
 
 	if (lp->resizefs) {
-		if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-				 lp->vg_name, lp->lv_name) < 0) {
-			log_error("Couldn't create LV path for %s",
-				  lp->lv_name);
-			return ECMD_FAILED;
-		}
-
-		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64,
-				 (uint64_t) lp->extents * vg->extent_size / 2)
-				 < 0) {
-			log_error("Couldn't generate new LV size string");
-			return ECMD_FAILED;
-		}
-
-		if (!lp->nofsck) {
-			if (!exec_cmd("fsadm", "check", lv_path, NULL)) {
-				stack;
-				return ECMD_FAILED;
-			}
-		}
-
-		if (lp->resize == LV_REDUCE) {
-			if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
-				stack;
-				return ECMD_FAILED;
-			}
-		}
+		if (!do_resizefs_reduce(cmd, vg, lv_path, lp))
+		    return ECMD_FAILED;
 	}
 
 	if (!archive(vg)) {


