From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:08 +0000 (GMT)
Subject: master - cov: avoid duplicated assign
Message-ID: <20200901170208.B861A3951CAE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56c41b7522d2a9ab12f15a65b8200545a47f5412
Commit:        56c41b7522d2a9ab12f15a65b8200545a47f5412
Parent:        a481f4263093d45eb4c4a7912ab3c6069ed05df9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 20:40:20 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cov: avoid duplicated assign

---
 lib/metadata/lv_manip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 95ca2df39..284d0e52b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7576,8 +7576,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 	struct device *dev;
 	char name[PATH_MAX];
 	uint64_t zero_sectors;
-	int zero_metadata = wp.is_metadata ?
-		find_config_tree_bool(lv->vg->cmd, allocation_zero_metadata_CFG, NULL) : 0;
+	int zero_metadata;
 
 	if (!wp.do_zero && !wp.do_wipe_signatures && !wp.is_metadata)
 		/* nothing to do */


