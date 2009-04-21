From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Apr 2009 12:56:53 +0200
Subject: [PATCH] Fix pvseg report for orphan PVs and other devices.
Message-ID: <49EDA675.9080902@redhat.com>
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
 tools/toollib.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bdca53f..8df9ed5 100644
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
+		ret = process_single(cmd, vg, &_free_pv_segment, handle);
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



