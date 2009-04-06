From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:31:06 +0200
Subject: [PATCH] use proper pv structure in process_each_segment_in_pv
Message-ID: <49D9BDCA.5060206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use pv from newly read vg to avoid possible unallocated memory use.

If the vg in process_each_segment_in_pv is NULL, the pv struct
can be incomplete (for example lv_segs are not copied in get_pvs()
call).

We need use the new pv from just read-in volume group.

(The same code is in pvdisplay already.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/toollib.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1a2fd01..aa2194c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -364,6 +364,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 						      void *handle))
 {
 	struct pv_segment *pvseg;
+	struct pv_list *pvl;
 	const char *vg_name = NULL;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -376,6 +377,18 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
+
+		/*
+		 * Replace possibly incomplete PV structure with new one
+		 * allocated in vg_read_internal() path.
+		 */
+		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
+			 log_error("Unable to find %s in volume group %s",
+				   pv_dev_name(pv), vg_name);
+			return ECMD_FAILED;
+		}
+
+		pv = pvl->pv;
 	}
 
 	dm_list_iterate_items(pvseg, &pv->segments) {



