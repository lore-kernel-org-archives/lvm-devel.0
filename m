From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  4 Dec 2012 23:53:48 +0000 (UTC)
Subject: master - pvmove/RAID: Disallow pvmove on RAID LVs until properly handled
Message-ID: <20121204235348.DFB7822DC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=383575525916d4cafb1c8396c95a40be539d1451
Commit:        383575525916d4cafb1c8396c95a40be539d1451
Parent:        35a4d70aad02f297d81909ff7c65a032c5e0dbf2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Dec 4 17:47:47 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Dec 4 17:47:47 2012 -0600

pvmove/RAID:  Disallow pvmove on RAID LVs until properly handled

Attempting pvmove on RAID LVs replaces the kernel RAID target with
a temporary pvmove target, ultimately destroying the RAID LV.  pvmove
must be prevented on RAID LVs for now.

Use 'lvconvert --replace old_pv vg/lv new_pv' if you want to move
an image of the RAID LV.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 519d4dd..b5b774f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Disallow pvmove on RAID LVs until they are addressed properly
   Allow empty activation/{auto_activation|read_only|}_volume_list config option.
   Add lvm.conf option global/thin_disabled_features.
   Add lvconvert support to swap thin pool metadata volume.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9649f11..fcc5b31 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -179,6 +179,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 						unsigned *exclusive)
 {
 	struct logical_volume *lv_mirr, *lv;
+	struct lv_segment *seg;
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
 	int lv_found = 0;
@@ -206,6 +207,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	/* Find segments to be moved and set up mirrors */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
+		seg = first_seg(lv);
 		if (lv == lv_mirr)
 			continue;
 		if (lv_name) {
@@ -218,6 +220,19 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
+		if (seg_is_raid(seg)) {
+			lv_skipped = 1;
+			log_print_unless_silent("Skipping %s LV %s",
+						seg->segtype->ops->name(seg),
+						lv->name);
+			continue;
+		}
+		if (lv_is_raid_type(lv)) {
+			lv_skipped = 1;
+			log_print_unless_silent("Skipping RAID sub-LV %s",
+						lv->name);
+			continue;
+		}
 		if (lv->status & MIRRORED) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping mirror LV %s", lv->name);


