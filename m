From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Sat, 22 Apr 2017 00:18:06 -0400
Subject: master - raid: avoid superfluous variable
Message-ID: <201704220418.v3M4I6Fi006488@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=97a5fa4b876ea861a5927ff714b617bb4c72efbc
Commit:        97a5fa4b876ea861a5927ff714b617bb4c72efbc
Parent:        effeb2b93d4840b906b1bfa45d05bea9ff8d11e6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 22 00:50:36 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 22 00:50:36 2017 +0200

raid: avoid superfluous variable

---
 lib/metadata/raid_manip.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 03e32c6..1563110 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4808,11 +4808,8 @@ static int _shift_parity_dev(struct lv_segment *seg)
 static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 {
 	struct lv_segment *seg = first_seg(lv);
-	struct dm_list removal_lvs;
 	uint32_t region_size = seg->region_size;
 
-	dm_list_init(&removal_lvs);
-
 	if (!(seg_is_raid4(seg) && segtype_is_raid5_n(new_segtype)) &&
 	    !(seg_is_raid5_n(seg) && segtype_is_raid4(new_segtype))) {
 		log_error("LV %s has to be of type raid4 or raid5_n to allow for this conversion.",
@@ -4841,6 +4838,7 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 	}
 
+	/* Have to clear rmeta LVs or the kernel will reject due to reordering disks */
 	if (!_clear_meta_lvs(lv))
 		return_0;
 
@@ -4853,7 +4851,7 @@ static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
 	seg->region_size = new_region_size ?: region_size;
 	seg->segtype = new_segtype;
 
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	init_mirror_in_sync(0);


