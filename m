From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:45 +0000 (UTC)
Subject: master - cleanup: use same type
Message-ID: <20151029113945.C742F60E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=33a8a2febf483df088ec8e1928d25a6705a18991
Commit:        33a8a2febf483df088ec8e1928d25a6705a18991
Parent:        f32f0bd2a7aeddb90d41f342d4213ef054e9d4fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:01:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:14:20 2015 +0100

cleanup: use same type

---
 lib/metadata/thin_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6b22ce5..2d3146f 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -216,7 +216,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	dm_percent_t percent;
-	int threshold = DM_PERCENT_1 *
+	dm_percent_t threshold = DM_PERCENT_1 *
 		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
 


