From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:24 +0000 (UTC)
Subject: master - coverity: drop unused assignments
Message-ID: <20160223204124.20B2C6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b92cb27609ed239814d1e0d36f77d41464b23bd
Commit:        9b92cb27609ed239814d1e0d36f77d41464b23bd
Parent:        eaaae185b7870372298502d076defab2c3486ed3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 19:57:56 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:16 2016 +0100

coverity: drop unused assignments

---
 tools/lvrename.c |    4 ++--
 tools/lvresize.c |    6 ++++--
 tools/vgrename.c |    3 +--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/tools/lvrename.c b/tools/lvrename.c
index 1f6e829..e37d8aa 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -81,7 +81,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
 	char *st;
-	int ret = ECMD_FAILED;
+	int ret;
 
 	if (argc == 3) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -169,6 +169,6 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 			      _lvrename_single);
 
 	destroy_processing_handle(cmd, handle);
-	return ret;
 
+	return ret;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index af6ce07..2c2df36 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -199,10 +199,12 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
 	struct lvresize_params lp = { 0 };
-	int ret = ECMD_FAILED;
+	int ret;
 
-	if (!_lvresize_params(cmd, argc, argv, &lp))
+	if (!_lvresize_params(cmd, argc, argv, &lp)) {
+		stack;
 		return EINVALID_CMD_LINE;
+	}
 
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 633999e..e5af820 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -38,7 +38,6 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct vgrename_params *vp = (struct vgrename_params *) handle->custom_handle;
-	struct lvmcache_vginfo *vginfo;
 	char old_path[NAME_LEN];
 	char new_path[NAME_LEN];
 	struct id id;
@@ -72,7 +71,7 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	 */
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if ((vginfo = lvmcache_vginfo_from_vgname(vp->vg_name_new, NULL))) {
+	if (lvmcache_vginfo_from_vgname(vp->vg_name_new, NULL)) {
 		log_error("New VG name \"%s\" already exists", vp->vg_name_new);
 		return ECMD_FAILED;
 	}


