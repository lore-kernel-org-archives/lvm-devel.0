From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Jul 2015 19:10:25 +0000 (UTC)
Subject: master - lockd: allow vgexport and vgimport
Message-ID: <20150713191025.F3C0360DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3da88b89172b588bef69d62e18ed5db127b2c845
Commit:        3da88b89172b588bef69d62e18ed5db127b2c845
Parent:        9cfa27f9c56edad26c2830562233b48e06bb4802
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 13 13:48:39 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 13 14:07:57 2015 -0500

lockd: allow vgexport and vgimport

The "exported" state of the VG can be useful with lockd VGs
because the exported state keeps a VG from being used in general.
It's a way to keep a VG protected and out of the way.

Also fix the command flags: ALL_VGS_IS_DEFAULT is not true for
vgimport/vgexport, since they both return errors immediately if
no VG args are specified.  LOCKD_VG_SH is not true for vgexport
beause it must use an ex lock to write the VG.
---
 tools/commands.h |    4 ++--
 tools/vgchange.c |   12 +++++++++---
 tools/vgexport.c |   25 ++++++++++++++++++-------
 tools/vgimport.c |    4 +++-
 4 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 43d5c80..e50505d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1191,7 +1191,7 @@ xx(vgdisplay,
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
-   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
+   0,
    "vgexport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1229,7 +1229,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT,
+   0,
    "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 95cffaf..0ed8fec 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -888,7 +888,8 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ systemid_ARG, &_vgchange_system_id },
 	};
 
-	if (vg_is_exported(vg)) {
+	if (vg_is_exported(vg) &&
+	    !(arg_is_set(cmd, lockstop_ARG) || arg_is_set(cmd, lockstart_ARG))) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
@@ -1052,6 +1053,7 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
+	uint32_t flags = 0;
 	int ret;
 
 	int noupdate =
@@ -1185,8 +1187,12 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!_lockd_vgchange(cmd, argc, argv))
 		return_ECMD_FAILED;
 
-	ret = process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
-			      NULL, &vgchange_single);
+	if (update)
+		flags |= READ_FOR_UPDATE;
+	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
+		flags |= READ_ALLOW_EXPORTED;
+
+	ret = process_each_vg(cmd, argc, argv, flags, NULL, &vgchange_single);
 
 	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
 
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 7e90e5c..566cc96 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -22,19 +22,30 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 {
 	struct pv_list *pvl;
 
-	/* vgexport/vgimport have to use with shared VGs. */
-	if (is_lockd_type(vg->lock_type)) {
-		log_error("Volume group \"%s\" has lock_type %s that cannot be exported",
-			  vg_name, vg->lock_type);
-		goto bad;
-	}
-
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
 			  vg_name);
 		goto bad;
 	}
 
+	if (is_lockd_type(vg->lock_type)) {
+		struct lv_list *lvl;
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (!lockd_lv_uses_lock(lvl->lv))
+				continue;
+
+			if (!lockd_lv(cmd, lvl->lv, "ex", 0)) {
+				log_error("LV %s/%s must be inactive on all hosts before vgexport.",
+					  vg->name, display_lvname(lvl->lv));
+				goto bad;
+			}
+
+			if (!lockd_lv(cmd, lvl->lv, "un", 0))
+				goto bad;
+		}
+	}
+
+
 	if (!archive(vg))
 		goto_bad;
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index b64a7a3..04a59dc 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -37,7 +37,9 @@ static int vgimport_single(struct cmd_context *cmd,
 		goto_bad;
 
 	vg->status &= ~EXPORTED_VG;
-	vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
+
+	if (!is_lockd_type(vg->lock_type))
+		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;


