From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Oct 2014 20:49:34 +0000 (UTC)
Subject: master - toollib: remove dead code
Message-ID: <20141015204934.249276117C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23a38d242bcc1187aa6ef36383311d789d43c82d
Commit:        23a38d242bcc1187aa6ef36383311d789d43c82d
Parent:        4461c624bc59ddca60f4bbf1eb447d64c8d4aeb2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 15 15:45:38 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 15 15:47:45 2014 -0500

toollib: remove dead code

Because of the recent change to process_each_pv(), the vg is always
provided when the pv is in a vg.  is_pv(pv) means the pv is in a vg,
which means that the vg arg will not be NULL, which means the removed
block of code is not needed.
---
 tools/toollib.c |   34 ++--------------------------------
 1 files changed, 2 insertions(+), 32 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 7f656c6..eba9a37 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -192,41 +192,15 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 {
 	struct pv_segment *pvseg;
 	struct pv_list *pvl;
-	const char *vg_name = NULL;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
-	struct volume_group *old_vg = vg;
 	struct pv_segment _free_pv_segment = { .pv = pv };
 
-	if (is_pv(pv) && !vg && !is_orphan(pv)) {
-		vg_name = pv_vg_name(pv);
-
-		vg = vg_read(cmd, vg_name, NULL, 0);
-		if (ignore_vg(vg, vg_name, 0, &ret_max)) {
-			release_vg(vg);
-			stack;
-			return ret_max;
-		}
-
-		/*
-		 * Replace possibly incomplete PV structure with new one
-		 * allocated in vg_read_internal() path.
-		 */
-		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
-			 log_error("Unable to find %s in volume group %s",
-				   pv_dev_name(pv), vg_name);
-			 unlock_and_release_vg(cmd, vg, vg_name);
-			 return ECMD_FAILED;
-		}
-
-		pv = pvl->pv;
-	}
-
 	if (dm_list_empty(&pv->segments)) {
 		ret = process_single_pvseg(cmd, NULL, &_free_pv_segment, handle);
 		if (ret > ret_max)
 			ret_max = ret;
-	} else
+	} else {
 		dm_list_iterate_items(pvseg, &pv->segments) {
 			if (sigint_caught()) {
 				ret_max = ECMD_FAILED;
@@ -237,11 +211,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			if (ret > ret_max)
 				ret_max = ret;
 		}
-
-	if (vg_name)
-		unlock_vg(cmd, vg_name);
-	if (!old_vg)
-		release_vg(vg);
+	}
 
 	return ret_max;
 }


