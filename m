From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Jul 2013 15:21:26 +0000 (UTC)
Subject: master - cleanup: use plain unsigned types
Message-ID: <20130705152126.D4F4461114@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a64239f225463d418dd4ccb931ceda88535fc6e2
Commit:        a64239f225463d418dd4ccb931ceda88535fc6e2
Parent:        9e79cca9e75e5c50b92744cb89be2e29853597ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 5 17:10:11 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 5 17:20:57 2013 +0200

cleanup: use plain unsigned types

---
 lib/metadata/metadata.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index deb967c..96a636c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2292,9 +2292,9 @@ int vg_validate(struct volume_group *vg)
 	struct str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
-	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
-	uint32_t pv_count = 0;
-	uint32_t num_snapshots = 0;
+	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
+	unsigned pv_count = 0;
+	unsigned num_snapshots = 0;
 	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
@@ -2432,10 +2432,10 @@ int vg_validate(struct volume_group *vg)
 	 * all volumes = visible LVs + snapshot_cows + invisible LVs
 	 */
 	if (lv_count != lv_visible_count + num_snapshots + hidden_lv_count) {
-		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs (%u) in VG %s",
-			  lv_count, lv_visible_count,
-			  num_snapshots, hidden_lv_count, vg->name);
+		log_error(INTERNAL_ERROR "#LVs (%u) != #visible LVs (%u) "
+			  "+ #snapshots (%u) + #internal LVs (%u) in VG %s",
+			  lv_count, lv_visible_count, num_snapshots,
+			  hidden_lv_count, vg->name);
 		r = 0;
 	}
 


