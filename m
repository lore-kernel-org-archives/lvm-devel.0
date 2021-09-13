From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:04 +0000 (GMT)
Subject: main - cache: implement better revert path
Message-ID: <20210913103604.B20883858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d489445e5accf550177141bf3b95283d2821386e
Commit:        d489445e5accf550177141bf3b95283d2821386e
Parent:        4c3d7a01d4a28c83b7992749c0ae8b7e9c145f3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 12 17:44:38 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cache: implement better revert path

When cache creation fails on table reload path, implemen more
advanced revert solution, that tries to restore state of LVM
metadata into is look before actual caching started.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 32 +++++++++++++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2da629297..e9a5de820 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Enhance recover path on cache creation failure.
   Filter out unsupported MQ/SMQ cache policy setting.
   Fix memleak in mpath filter.
   Support newer location for VDO statistics.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4bfedbe6e..4697ebbd8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8789,9 +8789,35 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return_NULL; /* revert? */
 
 		if (!lv_update_and_reload(lv)) {
-			/* FIXME Do a better revert */
-			log_error("Aborting. Manual intervention required.");
-			return NULL; /* FIXME: revert */
+			char name[NAME_LEN];
+
+			log_debug("Reverting created caching layer.");
+
+			tmp_lv = seg_lv(first_seg(lv), 0); /* tmp corigin */
+			pool_lv = first_seg(lv)->pool_lv;
+
+			if (!detach_pool_lv(first_seg(lv)))
+				return_NULL;
+			if (!remove_layer_from_lv(lv, tmp_lv))
+				return_NULL;
+			if (!lv_remove(tmp_lv))
+				return_NULL;
+
+			/* Either we need to preserve existing LV and remove created cache pool LV.
+			   Or we need to preserve existing cache pool LV and remove created new LV. */
+			if (origin_lv)
+				lv = pool_lv; // created cache pool to be reverted as new LV
+			else {
+				/* Cut off suffix _cpool from preserved existing cache pool */
+				if (!drop_lvname_suffix(name, pool_lv->name, "cpool")) {
+					/* likely older instance of metadata */
+					log_debug("LV %s has no suffix for cachepool (skipping rename).",
+						  display_lvname(pool_lv));
+				} else if (!lv_uniq_rename_update(cmd, pool_lv, name, 0))
+					return_NULL;
+			}
+
+			goto deactivate_and_revert_new_lv;
 		}
 	} else if (lp->snapshot) {
 		/* Deactivate zeroed COW, avoid any race usage */


