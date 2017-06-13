From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 13 Jun 2017 17:16:18 -0400
Subject: master - lvconvert: fix detached SubLV deactivation in cluster
Message-ID: <201706132116.v5DLGIk2016344@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08079ec42062944eadcd4e5625edafe45b36c55c
Commit:        08079ec42062944eadcd4e5625edafe45b36c55c
Parent:        9a094350e044100fdfb2270a18085e42e6f5ba3a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 13 23:15:51 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 13 23:15:51 2017 +0200

lvconvert: fix detached SubLV deactivation in cluster

On conversion from raid10 to raid0 (takeover), all rmeta
devices and the rimage devices of mirrored stripes are
detached from the raid10 LV. The remaining rimage areas
are being shifted down into the slots of the detached
ones hence requiring renames to show proper _N suffix
sequences (e.g. 0,1,2,3 instead of 0,2,4,6).  Only the
top-level raid10 LV has a cluster lock, not the detached
SubLVs thus their deactivation is impossible and e.g the
rename from *_rimage_6 to *_rimage_3 will fail.  Fix by
activating exclusively before deactivating and removing.

Resolves: rhbz1448123
---
 lib/metadata/raid_manip.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index fd51964..a19a7e9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -285,6 +285,17 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, removal_lvs) {
+		if (!lv_is_visible(lvl->lv)) {
+			log_error(INTERNAL_ERROR
+				  "LVs must be set visible before removing.");
+			return 0;
+		}
+		/* Got to get any cluster lock an SubLVs to be removed. */
+		if (!activate_lv_excl_local(vg->cmd, lvl->lv))
+			return_0;
+	}
+
+	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!deactivate_lv(vg->cmd, lvl->lv))
 			return_0;
 		if (!lv_remove(lvl->lv))


