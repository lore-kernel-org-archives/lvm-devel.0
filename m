From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Aug 2012 14:26:45 +0000 (UTC)
Subject: master - thin: fix condition for kernels without discards
Message-ID: <20120809142645.59B1834BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8a6efbcc03dd21cfc765176c3e406075bfa1e02
Commit:        b8a6efbcc03dd21cfc765176c3e406075bfa1e02
Parent:        1f1c664b78d5f8464e0bbee5a00402cad93c7029
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 9 11:25:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 9 16:24:42 2012 +0200

thin: fix condition for kernels without discards

Report warning if the kernel is not support given discards settings.
(In this case the behavior is equal to IGNORE.)
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7d3a2d..b0fa32f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.98
 =================================
   Use 'ignore' discards for thin metadata created with older versions.
+  Use proper condition to check for unsupported discards settings.
 
 Version 2.02.97 - 7th August 2012
 =================================
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 25c1947..d95b68e 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -276,13 +276,13 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
-	if ((seg->discards != THIN_DISCARDS_PASSDOWN) && (attr & THIN_FEATURE_DISCARDS)) {
+	if (attr & THIN_FEATURE_DISCARDS) {
 		/* FIXME: Check whether underlying dev supports discards */
 		if (!dm_tree_node_set_thin_pool_discard(node,
 							seg->discards == THIN_DISCARDS_IGNORE,
 							seg->discards == THIN_DISCARDS_NO_PASSDOWN))
 			return_0;
-	} else
+	} else if (seg->discards != THIN_DISCARDS_IGNORE)
 		log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
 				  "not support discards (needs kernel >= 3.4).");
 


