From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:09 +0000 (UTC)
Subject: master - tools: read yes_no_arg via int_value
Message-ID: <20141024144009.BB6E560E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=237c54802c88f0a7045d11642884c3d69e46180d
Commit:        237c54802c88f0a7045d11642884c3d69e46180d
Parent:        5bdf48b489660d1e99631fcb950c2094a9d158c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 11 18:17:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

tools: read yes_no_arg via int_value

yes_no_arg is already parsed so read parsed value as int.
---
 tools/lvchange.c  |   10 ++++------
 tools/lvconvert.c |    6 ++----
 tools/lvcreate.c  |   10 +++++-----
 tools/pvchange.c  |   15 +++------------
 tools/toollib.c   |   11 ++++-------
 tools/vgchange.c  |    4 ++--
 6 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6cb6f15..6697905 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -461,12 +461,10 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	int want_contiguous = 0;
-	alloc_policy_t alloc;
-
-	want_contiguous = strcmp(arg_str_value(cmd, contiguous_ARG, "n"), "n");
-	alloc = want_contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
-	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, alloc);
+	int want_contiguous = arg_int_value(cmd, contiguous_ARG, 0);
+	alloc_policy_t alloc = (alloc_policy_t)
+		arg_uint_value(cmd, alloc_ARG, (want_contiguous)
+			       ? ALLOC_CONTIGUOUS : ALLOC_INHERIT);
 
 	if (alloc == lv->alloc) {
 		log_error("Allocation policy of logical volume \"%s\" is "
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fc28846..9155998 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -559,10 +559,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
 			return_0;
 
-		lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
-						(lp->segtype->flags &
-						 SEG_CANNOT_BE_ZEROED) ?
-						"n" : "y"), "n");
+		lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
+			? 0 : arg_int_value(cmd, zero_ARG, 1);
 
 	} else if (arg_count(cmd, replace_ARG)) { /* RAID device replacement */
 		lp->replace_pv_count = arg_count(cmd, replace_ARG);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d849f93..5a91627 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -985,13 +985,13 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	/*
 	 * Should we zero/wipe signatures on the lv.
 	 */
-	lp->zero = (!(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) &&
-		    (strcmp(arg_str_value(cmd, zero_ARG, "y"), "y") == 0)) ? 1 : 0;
+	lp->zero = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
+		? 0 : arg_int_value(cmd, zero_ARG, 1);
 
 	if (arg_count(cmd, wipesignatures_ARG)) {
 		/* If -W/--wipesignatures is given on command line directly, respect it. */
-		lp->wipe_signatures =(!(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) &&
-				      (strcmp(arg_str_value(cmd, wipesignatures_ARG, "y"), "y") == 0)) ? 1 : 0;
+		lp->wipe_signatures = (lp->segtype->flags & SEG_CANNOT_BE_ZEROED)
+			? 0 : arg_int_value(cmd, wipesignatures_ARG, 1);
 	} else {
 		/*
 		 * If -W/--wipesignatures is not given on command line,
@@ -1047,7 +1047,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	/*
 	 * Allocation parameters
 	 */
-	contiguous = strcmp(arg_str_value(cmd, contiguous_ARG, "n"), "n");
+	contiguous = arg_int_value(cmd, contiguous_ARG, 0);
 
 	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index c2adc34..76db917 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -22,18 +22,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	const char *pv_name = pv_dev_name(pv);
 	char uuid[64] __attribute__((aligned(8)));
 
-	int allocatable = 0;
-	int tagargs = 0;
-	int mda_ignore = 0;
-
-	tagargs = arg_count(cmd, addtag_ARG) + arg_count(cmd, deltag_ARG);
-
-	if (arg_count(cmd, allocatable_ARG))
-		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
-				      "y");
-	if (arg_count(cmd, metadataignore_ARG))
-		mda_ignore = !strcmp(arg_str_value(cmd, metadataignore_ARG, "n"),
-				      "y");
+	int allocatable = arg_int_value(cmd, allocatable_ARG, 0);
+	int mda_ignore = arg_int_value(cmd, metadataignore_ARG, 0);
+	int tagargs = arg_count(cmd, addtag_ARG) + arg_count(cmd, deltag_ARG);
 
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index f81acca..a33e6c2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -643,9 +643,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	    arg_uint_value(cmd, physicalextentsize_ARG, vp_def->extent_size);
 
 	if (arg_count(cmd, clustered_ARG))
-		vp_new->clustered =
-			!strcmp(arg_str_value(cmd, clustered_ARG,
-					      vp_def->clustered ? "y":"n"), "y");
+		vp_new->clustered = arg_int_value(cmd, clustered_ARG, vp_def->clustered);
 	else
 		/* Default depends on current locking type */
 		vp_new->clustered = locking_is_clustered();
@@ -866,8 +864,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, zero_ARG))
-		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+	pp->zero = arg_int_value(cmd, zero_ARG, 1);
 
 	if (arg_sign_value(cmd, dataalignment_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume data alignment may not be negative");
@@ -966,7 +963,7 @@ int get_pool_params(struct cmd_context *cmd,
 	if (segtype_is_thin_pool(segtype) || segtype_is_thin(segtype)) {
 		if (arg_count(cmd, zero_ARG)) {
 			*passed_args |= PASS_ARG_ZERO;
-			*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+			*zero = arg_int_value(cmd, zero_ARG, 1);
 			log_very_verbose("Setting pool zeroing: %u", *zero);
 		}
 
@@ -1188,7 +1185,7 @@ int get_and_validate_major_minor(const struct cmd_context *cmd,
 				 const struct format_type *fmt,
 				 int32_t *major, int32_t *minor)
 {
-	if (strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
+	if (!arg_int_value(cmd, persistent_ARG, 0)) {
 		if (arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) {
 			log_error("--major and --minor incompatible with -Mn");
 			return 0;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 9a9fe48..af59f3a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -278,7 +278,7 @@ static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
 static int _vgchange_resizeable(struct cmd_context *cmd,
 				struct volume_group *vg)
 {
-	int resizeable = !strcmp(arg_str_value(cmd, resizeable_ARG, "n"), "y");
+	int resizeable = arg_int_value(cmd, resizeable_ARG, 0);
 
 	if (resizeable && vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" is already resizeable",
@@ -303,7 +303,7 @@ static int _vgchange_resizeable(struct cmd_context *cmd,
 static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
-	int clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
+	int clustered = arg_int_value(cmd, clustered_ARG, 0);
 
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",


