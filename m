From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Nov 2017 04:49:48 -0500
Subject: master - toollib: improve stripes args reading
Message-ID: <201711270949.vAR9nmUk022965@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34eb082bbcd57deb954ff4221c9320126c2096f3
Commit:        34eb082bbcd57deb954ff4221c9320126c2096f3
Parent:        f70404addb0f46b7dd281c2e7e0f944aa7f27ae5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 27 10:26:35 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 27 10:34:30 2017 +0100

toollib: improve stripes args reading

Rewrite validation of stripes and stripe_size args into more readable
sequential code.

Extend reading of stripes & stripes_size args so it better knows
defaults for types like striped raid.

TODO: this should really be a value obtained for segtype structure and
all the weird conditions and modification of stripes and stripe_size
around lvm2 code should be dropped.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   66 ++++++++++++++++++++++++++++++++----------------------
 2 files changed, 40 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f78b6c2..9b9e7a8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Enhance reading and validation of options stripes and stripes_size.
   Fix printing of default stripe size when user is not using stripes.
   Activation code for pvmove automatically discovers holding LVs for resume.
   Make a pvmove LV locking holder.
diff --git a/tools/toollib.c b/tools/toollib.c
index ffd9a4d..f60014c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1266,39 +1266,41 @@ int get_pool_params(struct cmd_context *cmd,
 static int _validate_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
 				   uint32_t *stripes, uint32_t *stripe_size)
 {
-	int stripe_size_required = segtype_supports_stripe_size(segtype);
+	if (*stripes < 1 || *stripes > MAX_STRIPES) {
+		log_error("Number of stripes (%d) must be between %d and %d.",
+			  *stripes, 1, MAX_STRIPES);
+		return 0;
+	}
 
-	if (!stripe_size_required && *stripe_size) {
-		log_print_unless_silent("Ignoring stripesize argument for %s devices.", segtype->name);
-		*stripe_size = 0;
-	} else if (*stripes == 1 && stripe_size_required) {
-		stripe_size_required = 0;
+	if (!segtype_supports_stripe_size(segtype)) {
+		if (*stripe_size) {
+			log_print_unless_silent("Ignoring stripesize argument for %s devices.",
+						segtype->name);
+			*stripe_size = 0;
+		}
+	} else if (*stripes == 1) {
 		if (*stripe_size) {
 			log_print_unless_silent("Ignoring stripesize argument with single stripe.");
 			*stripe_size = 0;
 		}
-	}
-
-	if (stripe_size_required) {
+	} else {
 		if (!*stripe_size) {
 			*stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 			log_print_unless_silent("Using default stripesize %s.",
 						display_size(cmd, (uint64_t) *stripe_size));
 		}
 
-		if (*stripe_size < STRIPE_SIZE_MIN || !is_power_of_2(*stripe_size)) {
+		if (*stripe_size > STRIPE_SIZE_LIMIT * 2) {
+			log_error("Stripe size cannot be larger than %s.",
+				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+			return 0;
+		} else if (*stripe_size < STRIPE_SIZE_MIN || !is_power_of_2(*stripe_size)) {
 			log_error("Invalid stripe size %s.",
 				  display_size(cmd, (uint64_t) *stripe_size));
 			return 0;
 		}
 	}
 
-	if (*stripes < 1 || *stripes > MAX_STRIPES) {
-		log_error("Number of stripes (%d) must be between %d and %d.",
-			  *stripes, 1, MAX_STRIPES);
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -1314,23 +1316,33 @@ int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtyp
 {
 	/* stripes_long_ARG takes precedence (for lvconvert) */
 	/* FIXME Cope with relative +/- changes for lvconvert. */
-	*stripes = arg_uint_value(cmd, arg_is_set(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
-	*stripes_supplied = arg_is_set(cmd, stripes_long_ARG) ? : arg_is_set(cmd, stripes_ARG);
+	if (arg_is_set(cmd, stripes_long_ARG)) {
+		*stripes = arg_uint_value(cmd, stripes_long_ARG, 0);
+		*stripes_supplied = 1;
+	} else if (arg_is_set(cmd, stripes_ARG)) {
+		*stripes = arg_uint_value(cmd, stripes_ARG, 0);
+		*stripes_supplied = 1;
+	} else {
+		/*
+		 * FIXME add segtype parameter for min_stripes and remove logic for this
+		 *       from all other places
+		 */
+		if (segtype_is_any_raid6(segtype))
+			*stripes = 3;
+		else if (segtype_is_striped_raid(segtype))
+			*stripes = 2;
+		else
+			*stripes = 1;
+		*stripes_supplied = 0;
+	}
 
-	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
-	*stripe_size_supplied = arg_is_set(cmd, stripesize_ARG);
-	if (*stripe_size) {
+	if ((*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0))) {
 		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative stripesize is invalid.");
 			return 0;
 		}
-
-		if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-			log_error("Stripe size cannot be larger than %s.",
-				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
-			return 0;
-		}
 	}
+	*stripe_size_supplied = arg_is_set(cmd, stripesize_ARG);
 
 	return _validate_stripe_params(cmd, segtype, stripes, stripe_size);
 }


