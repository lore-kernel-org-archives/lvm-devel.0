From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:59 +0000 (UTC)
Subject: master - cleanup: drop unused assignment
Message-ID: <20130421211659.023D51558@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd4fdce16c82225f7b8fce0b5ce294d8f3d2e4d6
Commit:        dd4fdce16c82225f7b8fce0b5ce294d8f3d2e4d6
Parent:        1951798d7225dce35baa7689a308998f27379b6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:09:28 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:04 2013 +0200

cleanup: drop unused assignment

Assigned values are unused.
---
 lib/activate/dev_manager.c |    2 +-
 lib/metadata/raid_manip.c  |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 00c0126..150bb35 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1610,7 +1610,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t s;
 	struct seg_list *sl;
 	struct dm_list *snh;
-	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment *seg;
 	struct dm_tree_node *thin_node;
 	const char *uuid;
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 707db1f..c0d38d8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -403,7 +403,6 @@ static int _alloc_image_component(struct logical_volume *lv,
 	}
 
 	if (!ah) {
-		first_area = 0;
 		log_error(INTERNAL_ERROR
 			  "Stand-alone %s area allocation not implemented",
 			  (type == RAID_META) ? "metadata" : "data");


