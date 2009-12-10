From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Dec 2009 13:53:58 +0100
Subject: [PATCH 2/4] Fix unlocking for vgrelease for error paths
In-Reply-To: <cover.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
Message-ID: <6cced8fbf2df8f9aea11306b0e43622f11d4a20d.1260449368.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/pvresize.c |    8 ++++++--
 tools/toollib.c  |    6 +++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/tools/pvresize.c b/tools/pvresize.c
index 7a911ac..292e3cc 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -60,8 +60,12 @@ static int _pv_resize_single(struct cmd_context *cmd,
 
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (vg_read_error(vg))
-			goto bad;
+		if (vg_read_error(vg)) {
+			vg_release(vg);
+			log_error("Unable to read volume group \"%s\".",
+				  vg_name);
+			return 0;
+		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
diff --git a/tools/toollib.c b/tools/toollib.c
index 33daf30..fce399b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -315,7 +315,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
 					log_error("strlist allocation failed");
-					vg_release(vg);
+					unlock_and_release_vg(cmd, vg, vgname);
 					return ECMD_FAILED;
 				}
 			}
@@ -367,8 +367,8 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
-			vg_release(vg);
-			return ECMD_FAILED;
+			 unlock_and_release_vg(cmd, vg, vg_name);
+			 return ECMD_FAILED;
 		}
 
 		pv = pvl->pv;
-- 
1.6.5.3


