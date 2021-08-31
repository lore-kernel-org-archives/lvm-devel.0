From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Aug 2021 20:06:09 +0000 (GMT)
Subject: main - vdo: support lvcreate with skipped activation
Message-ID: <20210831200609.3939F3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=419c93c87358ad311aa78dcd6fd8298325356df4
Commit:        419c93c87358ad311aa78dcd6fd8298325356df4
Parent:        4afe872fd6c43fcfcd519c862574d010cdbda653
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 31 21:34:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 31 22:05:47 2021 +0200

vdo: support lvcreate with skipped activation

Support creation of VDO LV for 'lvcreate -ky...'.
---
 lib/metadata/lv_manip.c    | 14 ++++++++++++++
 test/shell/lvcreate-vdo.sh |  2 +-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 730e3f0df..4bfedbe6e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8721,6 +8721,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			goto revert_new_lv;
 		}
 		lv->status &= ~LV_TEMPORARY;
+	} else if (seg_is_vdo_pool(lp)) {
+		lv->status |= LV_TEMPORARY;
+		if (!activate_lv(cmd, lv)) {
+			log_error("Aborting. Failed to activate temporary "
+				  "volume for VDO pool creation.");
+			goto revert_new_lv;
+		}
+		lv->status &= ~LV_TEMPORARY;
 	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV %s.", display_lvname(lv));
 		goto deactivate_and_revert_new_lv;
@@ -8747,6 +8755,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			stack;
 			goto deactivate_and_revert_new_lv;
 		}
+		if ((lv->status & LV_ACTIVATION_SKIP) &&
+		    !deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Couldn't deactivate VDO LV %s with skipped activation.",
+				  display_lvname(lv));
+			return NULL; /* Let's retry on error path */
+		}
 	} else if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
 		/* Finish cache conversion magic */
 		if (origin_lv) {
diff --git a/test/shell/lvcreate-vdo.sh b/test/shell/lvcreate-vdo.sh
index d66e35390..9fb2959db 100644
--- a/test/shell/lvcreate-vdo.sh
+++ b/test/shell/lvcreate-vdo.sh
@@ -79,7 +79,7 @@ not fsck -n "$DM_DEV_DIR/mapper/$vg-${lv2}"
 lvremove -ff $vg
 
 
-lvcreate --type vdo -L10G -V1T -n $lv1 $vg
+lvcreate --type vdo -L10G -V1T -ky -n $lv1 $vg
 lvs -a $vg
 lvremove -ff $vg
 


