From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 21:01:14 +0000 (UTC)
Subject: master - thin: fix recent commits
Message-ID: <20120807210115.128AA31D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ecccc3099c854bd9a993b360974a9f52a746131
Commit:        7ecccc3099c854bd9a993b360974a9f52a746131
Parent:        701b4a8363417b7d72a7255ca663991f3be95859
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 21:59:06 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 21:59:06 2012 +0100

thin: fix recent commits

---
 lib/thin/thin.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 5a044ee..cfd50ad 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -115,7 +115,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Could not read chunk_size");
 
 	if (dm_config_has_node(sn, "discards") &&
-	    !dm_config_get_str(sn, "discards", &discard_str))
+	    !dm_config_get_str(sn, "discards", &discards_str))
 		return SEG_LOG_ERROR("Could not read discards for");
 
 	if (!discards_str)
@@ -276,16 +276,15 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
-	if (seg->discards != THIN_DISCARDS_PASSDOWN)
-		if (attr & THIN_FEATURE_DISCARDS) {
-			/* FIXME: Check whether underlying dev supports discards */
-			if (!dm_tree_node_set_thin_pool_discard(node,
-								seg->discards == THIN_DISCARDS_IGNORE,
-								seg->discards == THIN_DISCARDS_NO_PASSDOWN))
-				return_0;
-		} else
-			log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
-					  "not support discards (needs kernel >= 3.4).");
+	if ((seg->discards != THIN_DISCARDS_PASSDOWN) && (attr & THIN_FEATURE_DISCARDS)) {
+		/* FIXME: Check whether underlying dev supports discards */
+		if (!dm_tree_node_set_thin_pool_discard(node,
+							seg->discards == THIN_DISCARDS_IGNORE,
+							seg->discards == THIN_DISCARDS_NO_PASSDOWN))
+			return_0;
+	} else
+		log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
+				  "not support discards (needs kernel >= 3.4).");
 
 	/*
 	 * Add messages only for activation tree.


