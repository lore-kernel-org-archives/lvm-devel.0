From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:47 +0000 (UTC)
Subject: master - lvconvert: remove unused code
Message-ID: <20170213181047.C360E60EFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=942dc07402747d00946c5e80d890d535c0cbd125
Commit:        942dc07402747d00946c5e80d890d535c0cbd125
Parent:        f067c0ad78cc894a2d620c38af4d74b679d5c316
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 10 11:34:12 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: remove unused code

For "split" which is not an alias for splitmirrors.
---
 tools/lvconvert.c |   46 +++++++---------------------------------------
 1 files changed, 7 insertions(+), 39 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1d7dc1b..2ccf264 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -24,7 +24,6 @@ typedef enum {
 	 *   For a mirrored or raid LV, split mirror into two mirrors, optionally tracking
 	 *     future changes to the main mirror to allow future recombination.
 	 */
-	CONV_SPLIT = 1,
 	CONV_SPLIT_MIRRORS = 2,
 
 	/* Every other segment type or mirror log conversion we haven't separated out */
@@ -33,7 +32,6 @@ typedef enum {
 
 struct lvconvert_params {
 	/* Exactly one of these 12 command categories is determined */
-	int split;		/* 1 */
 	int keep_mimages;	/* 2 */	/* --splitmirrors */
 	/* other */		/* 3 */
 
@@ -169,34 +167,21 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 		lp->mirrorlog = 1;
 	}
 
-	if (arg_is_set(cmd, split_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
-					    split_ARG,
-					    name_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->split = 1;
-		_set_conv_type(lp, CONV_SPLIT);
-	}
-	
 	if (arg_is_set(cmd, trackchanges_ARG))
 		lp->track_changes = 1;
 
-	if (lp->split) {
-		if ((lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL))) {
-			if (!validate_restricted_lvname_param(cmd, &vg_name, &lp->lv_split_name))
-				return_0;
-		}
-
-
 	/*
 	 * The '--splitmirrors n' argument is equivalent to '--mirrors -n'
 	 * (note the minus sign), except that it signifies the additional
 	 * intent to keep the mimage that is detached, rather than
 	 * discarding it.
 	 */
-	} else if (arg_is_set(cmd, splitmirrors_ARG)) {
+	if (arg_is_set(cmd, splitmirrors_ARG)) {
+		if ((lp->lv_split_name = arg_str_value(cmd, name_ARG, NULL))) {
+			if (!validate_restricted_lvname_param(cmd, &vg_name, &lp->lv_split_name))
+				return_0;
+		}
+
 		if (_mirror_or_raid_type_requested(cmd, lp->type_str)) {
 			log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 				  "mutually exclusive.");
@@ -217,20 +202,11 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 		_set_conv_type(lp, CONV_SPLIT_MIRRORS);
 		lp->mirrors = arg_uint_value(cmd, splitmirrors_ARG, 0);
 		lp->mirrors_sign = SIGN_MINUS;
-	} else {
-		if (lp->track_changes) {
-			log_error("--trackchanges is only valid with --splitmirrors.");
-			return 0;
-		}
-		if (arg_is_set(cmd, name_ARG)) {
-			log_error("The 'name' argument is only valid with --splitmirrors");
-			return 0;
-		}
 	}
 
 	/* If no other case was identified, then use of --stripes means --type striped */
 	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str &&
-	    !lp->split && !lp->mirrorlog && !lp->corelog &&
+	    !lp->mirrorlog && !lp->corelog &&
 	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
 		lp->type_str = SEG_TYPE_NAME_STRIPED;
 
@@ -251,21 +227,13 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 
 	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
-	/* We should have caught all these cases already. */
-	if (lp->split + lp->keep_mimages > 1) {
-		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
-		return 0;
-	}
-
 	/*
 	 * Final checking of each case:
-	 *   lp->split
 	 *   lp->keep_mimages
 	 *   --type mirror|raid  lp->mirrorlog lp->corelog
 	 *   --type raid0|striped
 	 */
 	switch(lp->conv_type) {
-	case CONV_SPLIT:
 	case CONV_SPLIT_MIRRORS:
                 break;
 


