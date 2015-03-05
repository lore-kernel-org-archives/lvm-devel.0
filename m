From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 16:13:01 +0000 (UTC)
Subject: master - system_id: undo the previous changes to the lvm1 code
Message-ID: <20150305161301.6FC8460E07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bb76aea81574042c6010291a8c799a90570b0d3
Commit:        8bb76aea81574042c6010291a8c799a90570b0d3
Parent:        1e65fdd9ba00ab249ab07d8b5815c398ded556e3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 5 10:13:05 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 10:13:05 2015 -0600

system_id: undo the previous changes to the lvm1 code

The system_id and lock_type compat changes do not apply
to the lvm1 code.
---
 lib/format1/disk-rep.h      |    2 --
 lib/format1/import-export.c |   16 ++--------------
 2 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 37f7282..9d1c8a5 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -41,7 +41,6 @@
 #define	VG_WRITE             0x02	/*     "     */
 #define	VG_CLUSTERED         0x04	/*     "     */
 #define	VG_SHARED            0x08	/*     "     */
-#define	VG_WRITE_LOCKED      0x10	/*     "     */
 
 /* logical volume */
 #define	LV_ACTIVE            0x01	/* lv_status */
@@ -52,7 +51,6 @@
 #define	LV_WRITE             0x02	/*     "     */
 #define	LV_SNAPSHOT          0x04	/*     "     */
 #define	LV_SNAPSHOT_ORG      0x08	/*     "     */
-#define	LV_WRITE_LOCKED      0x10	/*     "     */
 
 #define	LV_BADBLOCK_ON       0x01	/* lv_badblock */
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index b898e65..9b387e2 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -242,9 +242,6 @@ int import_vg(struct dm_pool *mem,
 	if (vgd->vg_access & VG_WRITE)
 		vg->status |= LVM_WRITE;
 
-	if (vgd->vg_access & VG_WRITE_LOCKED)
-		vg->status |= LVM_WRITE;
-
 	if (vgd->vg_access & VG_CLUSTERED)
 		vg->status |= CLUSTERED;
 
@@ -269,12 +266,9 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 	if (vg->status & LVM_READ)
 		vgd->vg_access |= VG_READ;
 
-	if ((vg->status & LVM_WRITE) && !vg_flag_write_locked(vg))
+	if (vg->status & LVM_WRITE)
 		vgd->vg_access |= VG_WRITE;
 
-	if ((vg->status & LVM_WRITE) && vg_flag_write_locked(vg))
-		vgd->vg_access |= VG_WRITE_LOCKED;
-
 	if (vg_is_clustered(vg))
 		vgd->vg_access |= VG_CLUSTERED;
 
@@ -326,9 +320,6 @@ int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
 	if (lvd->lv_access & LV_WRITE)
 		lv->status |= LVM_WRITE;
 
-	if (lvd->lv_access & LV_WRITE_LOCKED)
-		lv->status |= LVM_WRITE;
-
 	if (lvd->lv_badblock)
 		lv->status |= BADBLOCK_ON;
 
@@ -361,12 +352,9 @@ static void _export_lv(struct lv_disk *lvd, struct volume_group *vg,
 	if (lv->status & LVM_READ)
 		lvd->lv_access |= LV_READ;
 
-	if ((lv->status & LVM_WRITE) && !vg_flag_write_locked(vg))
+	if (lv->status & LVM_WRITE)
 		lvd->lv_access |= LV_WRITE;
 
-	if ((lv->status & LVM_WRITE) && vg_flag_write_locked(vg))
-		lvd->lv_access |= LV_WRITE_LOCKED;
-
 	if (lv->status & SPINDOWN_LV)
 		lvd->lv_status |= LV_SPINDOWN;
 


