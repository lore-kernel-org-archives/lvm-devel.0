From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Aug 2016 12:55:55 +0000 (UTC)
Subject: master - toollib: Record whether or not stripes/stripe_size args supplied.
Message-ID: <20160819125555.CFC9761869@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1a0a2c7121af78d469f3908d6a7763b51f377a5
Commit:        c1a0a2c7121af78d469f3908d6a7763b51f377a5
Parent:        c27963c56630417b7a91d073c9a73f54f3fb5c99
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 19 13:51:43 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 19 13:51:43 2016 +0100

toollib: Record whether or not stripes/stripe_size args supplied.

---
 lib/metadata/metadata-exported.h |    3 +++
 tools/lvconvert.c                |    9 ++++-----
 tools/lvcreate.c                 |    2 +-
 tools/toollib.c                  |    6 +++++-
 tools/toollib.h                  |    3 ++-
 5 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 97692dc..37db89c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -945,6 +945,9 @@ struct lvcreate_params {
 	uint32_t chunk_size; /* snapshot */
 	uint32_t region_size; /* mirror */
 
+	unsigned stripes_supplied; /* striped */
+	unsigned stripe_size_supplied; /* striped */
+
 	uint32_t mirrors; /* mirror */
 
 	uint32_t min_recovery_rate; /* RAID */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 23e3cd5..ac019ec 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -86,7 +86,8 @@ struct lvconvert_params {
 	sign_t mirrors_sign;
 	uint32_t stripes;
 	uint32_t stripe_size;
-	uint32_t stripe_size_supplied;
+	unsigned stripes_supplied;
+	unsigned stripe_size_supplied;
 	uint32_t read_ahead;
 	cache_mode_t cache_mode; /* cache */
 	const char *policy_name; /* cache */
@@ -3183,7 +3184,7 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return_0;
 
 		if (!get_stripe_params(cmd, get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED),
-				       &lp->stripes, &lp->stripe_size))
+				       &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
 			return_0;
 
 		if (!archive(vg))
@@ -4473,10 +4474,8 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
 	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
 		/* FIXME Handle +/- adjustments too? */
-		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size))
+		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
 			return_0;
-		/* FIXME Move this into the get function */
-		lp->stripe_size_supplied = arg_is_set(cmd, stripesize_ARG);
 
 		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
 			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a389d79..6fd0fb9 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1061,7 +1061,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 	if (!_lvcreate_name_params(cmd, &argc, &argv, lp) ||
 	    !_read_size_params(cmd, lp, lcp) ||
-	    !get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size) ||
+	    !get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied) ||
 	    (lp->create_pool &&
 	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
diff --git a/tools/toollib.c b/tools/toollib.c
index 4f8cbb4..4f4c315 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1318,13 +1318,17 @@ static int _validate_stripe_params(struct cmd_context *cmd, const struct segment
  * power of 2, we must divide UINT_MAX by four and add 1 (to round it
  * up to the power of 2)
  */
-int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype, uint32_t *stripes, uint32_t *stripe_size)
+int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
+		      uint32_t *stripes, uint32_t *stripe_size,
+		      unsigned *stripes_supplied, unsigned *stripe_size_supplied)
 {
 	/* stripes_long_ARG takes precedence (for lvconvert) */
 	/* FIXME Cope with relative +/- changes for lvconvert. */
 	*stripes = arg_uint_value(cmd, arg_is_set(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
+	*stripes_supplied = arg_is_set(cmd, stripes_long_ARG) ? : arg_is_set(cmd, stripes_ARG);
 
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
+	*stripe_size_supplied = arg_is_set(cmd, stripesize_ARG);
 	if (*stripe_size) {
 		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Negative stripesize is invalid.");
diff --git a/tools/toollib.h b/tools/toollib.h
index d5de733..531f690 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -197,7 +197,8 @@ int get_pool_params(struct cmd_context *cmd,
 		    int *zero);
 
 int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
-		      uint32_t *stripes, uint32_t *stripe_size);
+		      uint32_t *stripes, uint32_t *stripe_size,
+		      unsigned *stripes_supplied, unsigned *stripe_size_supplied);
 
 int get_cache_params(struct cmd_context *cmd,
 		     cache_mode_t *cache_mode,


