From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 22 Mar 2010 04:08:04 -0400 (EDT)
Subject: [PATCH] Add missing parentheses to an error message
Message-ID: <Pine.LNX.4.64.1003220407330.15382@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add missing parentheses to an error message

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/metadata/metadata.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.moje/lib/metadata/metadata.c
===================================================================
--- LVM2.moje.orig/lib/metadata/metadata.c	2010-03-22 09:04:16.000000000 +0100
+++ LVM2.moje/lib/metadata/metadata.c	2010-03-22 09:05:21.000000000 +0100
@@ -2202,7 +2202,7 @@ int vg_validate(struct volume_group *vg)
 	if (((uint32_t) dm_list_size(&vg->lvs)) !=
 	    vg_visible_lvs(vg) + snapshot_count(vg) + hidden_lv_count) {
 		log_error(INTERNAL_ERROR "#internal LVs (%u) != #LVs (%"
-			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs %u in VG %s",
+			  PRIu32 ") + #snapshots (%" PRIu32 ") + #internal LVs (%u) in VG %s",
 			  dm_list_size(&vg->lvs), vg_visible_lvs(vg),
 			  snapshot_count(vg), hidden_lv_count, vg->name);
 		r = 0;


