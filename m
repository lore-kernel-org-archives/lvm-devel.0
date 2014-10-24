From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:10 +0000 (UTC)
Subject: master - lvcreate: check for conflicting -Zy -Wy
Message-ID: <20141024144110.4AB4A60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=784c216d2beb21bf793d33d1ebf600ab30454bb7
Commit:        784c216d2beb21bf793d33d1ebf600ab30454bb7
Parent:        c7484a139a3b24d05459d8593309b518b4104172
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 20:50:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

lvcreate: check for conflicting -Zy -Wy

Let the finaly state of zero & wipe_signature to be
resolved later together with all the types.

Don't play with zero assigment and segtype flag
(i.e. thin-pool -Z  has different meaning).

Check if the passed options do allow requested zeroing/wiping.

lvcreate without -Z or -W will fallback to warning if the device
cannot be zeroed, however if user requested them explicitely
it will give user error.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   90 +++++++++++++++++++++++++++++++++---------------------
 2 files changed, 56 insertions(+), 35 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c3d56de..b1f8410 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Check for zeroing of volume after segment type is fully detected.
   Better support for persistent major and minor options with lvcreate.
   Refactor lvcreate towards more complete validation of all supported options.
   Support lvcreate --type linear.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2744b09..767405b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -588,19 +588,6 @@ static int _read_activation_params(struct cmd_context *cmd,
 	lp->activate = (activation_change_t)
 		arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
-	if (!is_change_activating(lp->activate)) {
-		if (lp->zero && !seg_is_thin(lp)) {
-			log_error("--activate n requires --zero n");
-			return 0;
-		}
-	} else if (lp->activate == CHANGE_AAY) {
-		if (arg_count(cmd, zero_ARG) || arg_count(cmd, wipesignatures_ARG)) {
-			log_error("-Z and -W is incompatible with --activate a");
-			return 0;
-		}
-		lp->zero = 0;
-	}
-
 	/* Read ahead */
 	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 					cmd->default_settings.read_ahead);
@@ -616,13 +603,6 @@ static int _read_activation_params(struct cmd_context *cmd,
 			 "of %uK page size.", lp->read_ahead, pagesize >> 1);
 	}
 
-	/* Permissions */
-	if (!(lp->permission & LVM_WRITE)) {
-		/* Must not zero/wipe read only volume */
-		lp->zero = 0;
-		lp->wipe_signatures = 0;
-	}
-
 	/* Persistent minor (and major), default 'n' */
 	if (!get_and_validate_major_minor(cmd, vg->fid->fmt, &lp->major, &lp->minor))
 		return_0;
@@ -636,13 +616,6 @@ static int _read_activation_params(struct cmd_context *cmd,
 	if (arg_is_set(cmd, ignoreactivationskip_ARG))
 		lp->activation_skip |= ACTIVATION_SKIP_IGNORE;
 
-	if (lp->zero && (lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED)
-	    && !(lp->activation_skip & ACTIVATION_SKIP_IGNORE)) {
-		log_error("--setactivationskip y requires either --zero n "
-			  "or --ignoreactivationskip");
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -984,16 +957,12 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * Should we zero/wipe signatures on the lv.
-	 */
-	lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
-		? 0 : arg_int_value(cmd, zero_ARG, 1);
+	/* Should we zero/wipe signatures on the lv, default to 'y' */
+	lp->zero = arg_int_value(cmd, zero_ARG, 1);
 
-	if (arg_count(cmd, wipesignatures_ARG)) {
+	if (arg_is_set(cmd, wipesignatures_ARG)) {
 		/* If -W/--wipesignatures is given on command line directly, respect it. */
-		lp->wipe_signatures = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
-			? 0 : arg_int_value(cmd, wipesignatures_ARG, 1);
+		lp->wipe_signatures = arg_int_value(cmd, wipesignatures_ARG, 1);
 	} else {
 		/*
 		 * If -W/--wipesignatures is not given on command line,
@@ -1346,6 +1315,53 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * Check zero_ARG with default value set to value of wipesignatures_ARG
+ * with its default set to 'n'. So if user specifies on command line either
+ * -Zy or -Wy it will check for incompatible options will report error then.
+ *
+ * Catching cases like we cannot fulfill:
+ *   lvcreate [-an][-pr][-aay][-ky]  [-Zy][-Wy]
+ */
+static int _check_zero_parameters(struct cmd_context *cmd, struct lvcreate_params *lp)
+{
+	char buf[NAME_LEN + 128];
+
+	/* -Z has different meaning for thins */
+	if (seg_is_thin(lp))
+		return 1;
+
+	/* If there is some problem, buffer will not be empty */
+	if (dm_snprintf(buf, sizeof(buf), "%s%s%s%s%s%s%s",
+			lp->origin_name ? "origin " : "",
+			lp->origin_name ? : "",
+			lp->origin_name ? " " : "",
+			!(lp->permission & LVM_WRITE) ? "read-only " : "",
+			!is_change_activating(lp->activate) ? "inactive " : "",
+			(lp->activate == CHANGE_AAY) ? "auto activated " : "",
+			((lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED) &&
+			 !(lp->activation_skip & ACTIVATION_SKIP_IGNORE))
+			? "skipped from activation " : "") < 0) {
+		log_error(INTERNAL_ERROR "Buffer is too small for dm_snprintf().");
+		return 0;
+	}
+
+	if (buf[0] || (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)) {
+		/* Found condition that prevents zeroing */
+		if (arg_int_value(cmd, zero_ARG, arg_int_value(cmd, wipesignatures_ARG, 0))) {
+			if (!(lp->segtype->flags & SEG_CANNOT_BE_ZEROED)) {
+				log_error("Cannot zero %slogical volume with option -Zy or -Wy.", buf);
+				return 0;
+			}
+			log_print_unless_silent("Ignoring option -Zy or -Wy for unzeroable %s volume.",
+						lp->segtype->name);
+		}
+		lp->zero = lp->wipe_signatures = 0;
+	}
+
+	return 1;
+}
+
 
 /*
  * Ensure the set of thin parameters extracted from the command line is consistent.
@@ -1429,6 +1445,10 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!_check_pool_parameters(cmd, vg, &lp, &lcp))
 		goto_out;
 
+	/* All types are checked */
+	if (!_check_zero_parameters(cmd, &lp))
+		return_0;
+
 	if (!_update_extents_params(vg, &lp, &lcp))
 		goto_out;
 


