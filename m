From: Milan Broz <mbroz@redhat.com>
Date: Tue, 03 Nov 2009 17:19:29 +0100
Subject: [PATCH] fix processing of %PVS arg in lvcreate
Message-ID: <4AF05811.20600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix lvcreate processing of %PVS argument.

- fix missing unlocking of VG
lvcreate -l 100%PVS -n lv1 vg_test
  Please specify physical volume(s) with %PVS
  Internal error: Volume Group vg_test was not unlocked

- if no PVS specified, use all available

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index be6b5cc..0ef04d9 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -161,13 +161,12 @@ static int _update_extents_params(struct volume_group *vg,
 			lp->extents = lp->extents * vg->free_count / 100;
 			break;
 		case PERCENT_PVS:
-			if (!lcp->pv_count) {
-				log_error("Please specify physical volume(s) "
-					  "with %%PVS");
-				return 0;
+			if (!lcp->pv_count)
+				lp->extents = lp->extents * vg->extent_count / 100;
+			else {
+				pv_extent_count = pv_list_extents_free(lp->pvh);
+				lp->extents = lp->extents * pv_extent_count / 100;
 			}
-			pv_extent_count = pv_list_extents_free(lp->pvh);
-			lp->extents = lp->extents * pv_extent_count / 100;
 			break;
 		case PERCENT_LV:
 			log_error("Please express size as %%VG, %%PVS, or "
@@ -591,15 +590,15 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!_update_extents_params(vg, &lp, &lcp)) {
-		stack;
-		return ECMD_FAILED;
+		r = ECMD_FAILED;
+		goto_out;
 	}
 
 	if (!lv_create_single(vg, &lp)) {
 		stack;
 		r = ECMD_FAILED;
 	}
-
+out:
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }



