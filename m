From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  2 Nov 2012 15:33:10 -0500
Subject: [PATCH 3/3] lvm2app: Implement lvm_lv_resize
In-Reply-To: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
References: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
Message-ID: <1351888390-12619-4-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Additionally, renamed _lvresize to lv_resize.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 liblvm/lvm_lv.c                  |   19 ++++++++++++++++---
 tools/lvresize.c                 |    2 +-
 4 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index aa526e8..43f13b4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3251,7 +3251,7 @@ int fsadm_cmd(struct cmd_context *cmd,
 	return exec_cmd(cmd, argv, status, 1);
 }
 
-int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
+int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp, struct dm_list *pvh)
 {
 	struct logical_volume *lv;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f43e957..f0a7b7a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -520,7 +520,7 @@ int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_to);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
-int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
+int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp, struct dm_list *pvh);
 
 int fsadm_cmd(struct cmd_context *cmd,
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d47a857..b22ba11 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -304,7 +304,20 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
-	/* FIXME: add lv resize code here */
-	log_error("NOT IMPLEMENTED YET");
-	return -1;
+	struct lvresize_params lp = { 0 };
+
+	lp.vg_name = lv->vg->name;
+	lp.lv_name = lv->name;
+	lp.sign = SIGN_NONE;
+	lp.percent = PERCENT_NONE;
+	lp.resize = LV_ANY;
+	lp.size = new_size >> SECTOR_SHIFT;
+	lp.ac_force = 1;	/* Assume the user has a good backup? */
+
+	if (ECMD_PROCESSED != lv_resize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
+		log_verbose("LV Re-size failed.");
+		return -1;
+	}
+
+	return 0;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index e2ab990..ef79fad 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -175,7 +175,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	r = _lvresize(cmd, vg, &lp, pvh);
+	r = lv_resize(cmd, vg, &lp, pvh);
 
 	if (ECMD_PROCESSED == r) {
 		if (!vg_write(vg)) {
-- 
1.7.1


