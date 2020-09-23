From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:34 +0000 (GMT)
Subject: master - lvconvert: suppport vdo raid conversion also through vpool
Message-ID: <20200923125934.73879398E477@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90c50c1b537dd89b62dad3047e27420d411293f5
Commit:        90c50c1b537dd89b62dad3047e27420d411293f5
Parent:        50a37948b5b2245a8f5d7d78aa88fa0679dfe0e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 14:44:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 14:47:30 2020 +0200

lvconvert: suppport vdo raid conversion also through vpool

User could directly use 'vdopool' LV name for conversion into raid.
(lvconvert --type raid1 vg/vdopool)
---
 tools/lvconvert.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 780a81567..60c0fca21 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1790,6 +1790,9 @@ static int _lvconvert_raid_types(struct cmd_context *cmd, struct logical_volume
 	if (lv_is_cache(lv))
 		lv = seg_lv(first_seg(lv), 0);
 
+	if (lv_is_vdo_pool(lv))
+		return _lvconvert_raid_types(cmd, seg_lv(first_seg(lv), 0), lp);
+
 	if (lv_is_mirror(lv)) {
 		ret = _convert_mirror(cmd, lv, lp);
 		goto out;
@@ -5064,6 +5067,7 @@ static int _lvconvert_raid_types_check(struct cmd_context *cmd, struct logical_v
 		    !lv_is_cache_pool_data(lv) &&
 		    !lv_is_thin_pool_metadata(lv) &&
 		    !lv_is_thin_pool_data(lv) &&
+		    !lv_is_vdo_pool_data(lv) &&
 		    !lv_is_used_cache_pool(lv) &&
 		    !lv_is_mirrored(lv) &&
 		    !lv_is_raid(lv))


