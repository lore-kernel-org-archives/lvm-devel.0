From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Apr 2009 14:31:50 +0200
Subject: [PATCH v2] Fix pvseg report for orphan PVs and other devices.
In-Reply-To: <49EDA675.9080902@redhat.com>
References: <49EDA675.9080902@redhat.com>
Message-ID: <49EDBCB6.30903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix pvseg report for orphan PVs and other devices.

If user requests report attribute from PVSEG type
and PV is orphan (or all devices is set), the report
is empty.

Try for example (when only orphan PV are present)
 #pvs
 #pvs -o +devices
# pvs /dev/sdb1
  PV         VG   Fmt  Attr PSize  PFree
    /dev/sdb1       lvm2 --   46.58G 46.58G
# pvs -o +devices /dev/sdb1
(no output)

The problem is caused by empty pv->segments list.

Fix it by providing fake segment here (similar to fake structures
in _pvsegs_sub_single() calls.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-listings.sh |    4 ++++
 tools/reporter.c   |   12 ++++++++++--
 tools/toollib.c    |   16 +++++++++++-----
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/test/t-listings.sh b/test/t-listings.sh
index e6da5b0..9ea10b6 100644
--- a/test/t-listings.sh
+++ b/test/t-listings.sh
@@ -34,6 +34,10 @@ pvcreate --metadatacopies 0 $dev5
 pvs --noheadings|tee out
 test $(wc -l <out) -eq 5
 
+#COMM pvs with segment attributes works even for orphans
+pvs --noheadings -o  seg_all,pv_all,lv_all,vg_all | tee out
+test $(wc -l <out) -eq 5
+
 vgcreate -c n $vg $devs
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
diff --git a/tools/reporter.c b/tools/reporter.c
index 9d03f58..0a9de09 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -54,15 +54,20 @@ static int _segs_single(struct cmd_context *cmd __attribute((unused)),
 	return ECMD_PROCESSED;
 }
 
-static int _pvsegs_sub_single(struct cmd_context *cmd __attribute((unused)),
+static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct pv_segment *pvseg, void *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 
+	struct volume_group _free_vg = {
+		.cmd = cmd,
+		.name = (char *)"",
+	};
+
 	struct logical_volume _free_logical_volume = {
-		.vg = vg,
+		.vg = vg ?: &_free_vg,
 		.name = (char *) "",
 	        .snapshot = NULL,
 		.status = VISIBLE_LV,
@@ -88,6 +93,9 @@ static int _pvsegs_sub_single(struct cmd_context *cmd __attribute((unused)),
 
         _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
+	dm_list_init(&_free_vg.pvs);
+	dm_list_init(&_free_vg.lvs);
+	dm_list_init(&_free_vg.tags);
 	dm_list_init(&_free_lv_segment.tags);
 	dm_list_init(&_free_lv_segment.origin_list);
 	dm_list_init(&_free_logical_volume.tags);
diff --git a/tools/toollib.c b/tools/toollib.c
index bdca53f..ae600c7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -375,6 +375,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct volume_group *old_vg = vg;
+	struct pv_segment _free_pv_segment = { .pv = pv };
 
 	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
@@ -399,13 +400,18 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		pv = pvl->pv;
 	}
 
-	dm_list_iterate_items(pvseg, &pv->segments) {
-		ret = process_single(cmd, vg, pvseg, handle);
+	if (dm_list_empty(&pv->segments)) {
+		ret = process_single(cmd, NULL, &_free_pv_segment, handle);
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
-			break;
-	}
+	} else
+		dm_list_iterate_items(pvseg, &pv->segments) {
+			ret = process_single(cmd, vg, pvseg, handle);
+			if (ret > ret_max)
+				ret_max = ret;
+			if (sigint_caught())
+				break;
+		}
 
 	if (vg_name)
 		unlock_vg(cmd, vg_name);



