From: Milan Broz <mbroz@redhat.com>
Date: Fri, 25 Jun 2010 18:59:32 +0200
Subject: [PATCH] Fix handling of partial VG for lvm1 format metadata
Message-ID: <1277485172-16605-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If some lvm1 device is missing, lvm fails on all operations
# vgcfgbackup -f bck -P vg_test
  Partial mode. Incomplete volume groups will be activated read-only.
  3 PV(s) found for VG vg_test: expected 4
  PV segment VG free_count mismatch: 152599 != 228909
  PV segment VG extent_count mismatch: 152600 != 228910
  Internal error: PV segments corrupted in vg_test.
  Volume group "vg_test" not found

Allow loading of lvm1 partial VG by allocating "new" missing PV,
which covers lost space. Also this fake mising PV inform code
that it is partial VG.

(Not that this is so important, code is broken since 2005,
but once I have a patch... :-)

https://bugzilla.redhat.com/show_bug.cgi?id=501390
---
 lib/format1/format1.c       |   51 +++++++++++++++++++++++++++++++++++++++++-
 test/t-vgcfgbackup-usage.sh |    9 +++++++
 2 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 1167e04..9231b77 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -21,9 +21,10 @@
 #include "lvm1-label.h"
 #include "format1.h"
 #include "segtype.h"
+#include "pv_alloc.h"
 
 /* VG consistency checks */
-static int _check_vgs(struct dm_list *pvs)
+static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
 {
 	struct dm_list *pvh, *t;
 	struct disk_list *dl = NULL;
@@ -105,11 +106,53 @@ static int _check_vgs(struct dm_list *pvs)
 	if (pv_count != first->vgd.pv_cur) {
 		log_error("%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
+		vg->status |= PARTIAL_VG;
 	}
 
 	return 1;
 }
 
+static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
+{
+	uint32_t extent_count = 0;
+	struct disk_list *dl;
+	struct dm_list *pvh;
+	struct pv_list *pvl;
+
+	dm_list_iterate(pvh, pvs) {
+		dl = dm_list_item(pvh, struct disk_list);
+		extent_count += dl->pvd.pe_total;
+	}
+
+	/* FIXME: move this to one place to pv_manip */
+	if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl))) ||
+	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
+		return_0;
+
+	if (!id_create(&pvl->pv->id))
+		goto_out;
+	if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vg->name)))
+		goto_out;
+	memcpy(&pvl->pv->vgid, &vg->id, sizeof(vg->id));
+	pvl->pv->status |= MISSING_PV;
+	dm_list_init(&pvl->pv->tags);
+	dm_list_init(&pvl->pv->segments);
+
+	pvl->pv->pe_size = vg->extent_size;
+	pvl->pv->pe_count = vg->extent_count - extent_count;
+	if (!alloc_pv_segment_whole_pv(vg->vgmem, pvl->pv))
+		goto_out;
+
+	add_pvl_to_vgs(vg, pvl);
+	log_debug("%s: partial VG, allocated missing PV using %d extents.",
+		  vg->name, pvl->pv->pe_count);
+
+	return 1;
+out:
+	dm_pool_free(vg->vgmem, pvl);
+	return 0;
+}
+
 static struct volume_group *_build_vg(struct format_instance *fid,
 				      struct dm_list *pvs,
 				      struct dm_pool *mem)
@@ -134,7 +177,7 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
-	if (!_check_vgs(pvs))
+	if (!_check_vgs(pvs, vg))
 		goto_bad;
 
 	dl = dm_list_item(pvs->n, struct disk_list);
@@ -154,6 +197,10 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	if (!import_snapshots(mem, vg, pvs))
 		goto_bad;
 
+	/* Fix extents counts by adding missing PV if partial VG */
+	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, pvs))
+		goto_bad;
+
 	return vg;
 
       bad:
diff --git a/test/t-vgcfgbackup-usage.sh b/test/t-vgcfgbackup-usage.sh
index e1e94b3..e9a2609 100644
--- a/test/t-vgcfgbackup-usage.sh
+++ b/test/t-vgcfgbackup-usage.sh
@@ -40,3 +40,12 @@ sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backu
 pvcreate -ff -y -u $pv1_uuid $dev1
 pvcreate -ff -y -u $pv2_uuid $dev2
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
+vgremove -ff $vg
+
+# vgcfgbackup correctly stores metadata LVM1 with missing PVs
+pvcreate -M1 $devs
+vgcreate -M1 $vg $devs
+lvcreate -l1 -n $lv1 $vg $dev1
+pvremove -ff -y $dev2
+not lvcreate -l1 -n $lv1 $vg $dev3
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
-- 
1.7.1


