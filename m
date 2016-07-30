From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Jul 2016 17:20:58 +0000 (UTC)
Subject: master - lvconvert: Set lp->segtype in only one place.
Message-ID: <20160730172058.8180560324@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0df1ff995f3270232ec5179057482c558119a92
Commit:        d0df1ff995f3270232ec5179057482c558119a92
Parent:        1ce958bc5ea2827fdb945b2177616e8f253486a1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 30 18:12:57 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 30 18:20:04 2016 +0100

lvconvert: Set lp->segtype in only one place.

---
 tools/lvconvert.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ed3bd88..dd0102f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -331,6 +331,7 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 {
 	int cachepool = 0;
 	int thinpool = 0;
+	struct segment_type *segtype;
 
 	if ((lp->pool_data_name = arg_str_value(cmd, cachepool_ARG, NULL))) {
 		if (lp->type_str[0] &&
@@ -388,10 +389,10 @@ static int _read_pool_params(struct cmd_context *cmd, int *pargc, char ***pargv,
 					 splitmirrors_ARG, splitsnapshot_ARG, -1))
 			return_0;
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+		if (!(segtype = get_segtype_from_string(cmd, lp->type_str)))
 			return_0;
 
-		if (!get_pool_params(cmd, lp->segtype, &lp->passed_args,
+		if (!get_pool_params(cmd, segtype, &lp->passed_args,
 				     &lp->pool_metadata_size,
 				     &lp->poolmetadataspare,
 				     &lp->chunk_size, &lp->discards,
@@ -528,7 +529,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->type_str = SEG_TYPE_NAME_THIN;
 	}
 
-	/* May set lp->segtype */
 	if (!_read_pool_params(cmd, &argc, &argv, lp))
 		return_0;
 
@@ -797,17 +797,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->pv_count = argc;
 	lp->pvs = argv;
 
-	/* If we have type_str, set up the segtype to match. */
-	if (*lp->type_str && !(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-		return_0;
-
-	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
-		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel.", lp->segtype->name);
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -4372,9 +4361,18 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	/* If we don't have a specific new segtype to use, keep the existing one. */
-	if (!lp->segtype)
+	/* Set up segtype either from type_str or else to match the existing one. */
+	if (!*lp->type_str)
 		lp->segtype = seg->segtype;
+	else if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
+		return_0;
+
+	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
+	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel.", lp->segtype->name);
+		return 0;
+	}
 
 	/* Process striping parameters */
 	/* FIXME This is incomplete */


