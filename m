From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:03:04 +0000 (UTC)
Subject: master - pvmove.c: code cleanup
Message-ID: <20150519190304.0E71060FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f400f9db19324a29aeff6ad92039db91adc1e8f9
Commit:        f400f9db19324a29aeff6ad92039db91adc1e8f9
Parent:        7a8ce8dbf73fc149c67b22e3b90f542f70944e93
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 15:27:36 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:56:24 2015 +0200

pvmove.c: code cleanup

---
 tools/pvmove.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index d5b246f..f4b9d6c 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -585,10 +585,11 @@ static int _copy_id_components(struct cmd_context *cmd,
 }
 
 static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
-			  int argc, char **argv, union lvid *lvid, char **vg_name,
+			  int argc, char **argv, union lvid *lvid, char **vg_name_copy,
 			  char **lv_mirr_name)
 {
 	const char *lv_name = NULL;
+	const char *vg_name;
 	char *pv_name_arg;
 	struct volume_group *vg;
 	struct dm_list *source_pvl;
@@ -611,9 +612,10 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		return EINVALID_CMD_LINE;
 	}
 
+	vg_name = pv_vg_name(pv);
+
 	if (arg_count(cmd, name_ARG)) {
-		if (!(lv_name = _extract_lvname(cmd, pv_vg_name(pv),
-						arg_value(cmd, name_ARG)))) {
+		if (!(lv_name = _extract_lvname(cmd, vg_name, arg_value(cmd, name_ARG)))) {
 			stack;
 			free_pv_fid(pv);
 			return EINVALID_CMD_LINE;
@@ -627,9 +629,9 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	}
 
 	/* Read VG */
-	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
+	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	vg = vg_read(cmd, pv_vg_name(pv), NULL, READ_FOR_UPDATE);
+	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
@@ -686,7 +688,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
-	if (!_copy_id_components(cmd, lv_mirr, vg_name, lv_mirr_name, lvid))
+	if (!_copy_id_components(cmd, lv_mirr, vg_name_copy, lv_mirr_name, lvid))
 		goto out;
 
 	if (flags & PVMOVE_FIRST_TIME)
@@ -697,15 +699,16 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	r = ECMD_PROCESSED;
 out:
 	free_pv_fid(pv);
-	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
 
 static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_name,
-				     union lvid *lvid, char **vg_name, char **lv_name,
-				     unsigned *in_progress)
+				     union lvid *lvid, char **vg_name_copy,
+				     char **lv_name_copy, unsigned *in_progress)
 {
 	int ret = 0;
+	const char *vg_name;
 	struct logical_volume *lv;
 	struct physical_volume *pv;
 	struct volume_group *vg;
@@ -718,8 +721,10 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 	if (!(pv = find_pv_by_name(cmd, pv_name, 0, 0)))
 		return_0;
 
+	vg_name = pv_vg_name(pv);
+
 	/* need read-only access */
-	vg = vg_read(cmd, pv_vg_name(pv), NULL, 0);
+	vg = vg_read(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		log_error("ABORTING: Can't read VG for %s.", pv_name);
 		release_vg(vg);
@@ -732,12 +737,12 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 					pv_name);
 		ret = 1;
 		*in_progress = 0;
-	} else if (_copy_id_components(cmd, lv, vg_name, lv_name, lvid)) {
+	} else if (_copy_id_components(cmd, lv, vg_name_copy, lv_name_copy, lvid)) {
 		ret = 1;
 		*in_progress = 1;
 	}
 
-	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_release_vg(cmd, vg, vg_name);
 	free_pv_fid(pv);
 	return ret;
 }


