From: Milan Broz <mbroz@redhat.com>
Date: Tue, 26 May 2009 15:23:25 +0200
Subject: [PATCH] Fix convert polling to ignore LV with different UUID.
Message-ID: <4A1BED4D.50401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix convert polling to ignore LV with different UUID.

When mirror convert polling is started (mainly as backgound process,
in lvchange -a y or in lvconvert itself) it tries to read VG
and LV identified by its name.

Unfortunatelly, the VG can have already different LV under the same name,
and various more or less funny things can happen (note that 
_finish_lvconvert_mirror suspends the volume for example).

(the typical example is our testing script which continuously recreates
LVs under the same name in the same VG.)

This patch adds optional uuid paramater which helps to properly
select the monitoring object. For lvconvert polling it is set to LV UUID
and both _get_lvconvert_vg and _get_lvconvert_lv uses it to read proper VG/LV.

(In the pvmove case it is NULL, here we poll for physical volume name).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/mirror.c            |    7 ++++---
 tools/lvchange.c                 |   10 +---------
 tools/lvconvert.c                |   37 +++++++++++++++++++++++++++++--------
 tools/polldaemon.c               |   11 ++++++-----
 tools/polldaemon.h               |    7 +++++--
 tools/pvmove.c                   |    4 ++--
 tools/tools.h                    |    2 +-
 8 files changed, 49 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 022c44b..30725d6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -621,6 +621,7 @@ struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  struct volume_group *vg,
 						  const char *name,
+						  const char *uuid,
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 53ec33e..5a52cfb 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1058,9 +1058,10 @@ struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 }
 
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
-					 	  struct volume_group *vg,
-				      		  const char *name,
-				      		  uint32_t lv_type)
+						  struct volume_group *vg,
+						  const char *name,
+						  const char *uuid __attribute((unused)),
+						  uint32_t lv_type)
 {
 	struct physical_volume *pv;
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4a314a3..beb8beb 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -106,8 +106,6 @@ static int lvchange_availability(struct cmd_context *cmd,
 {
 	int activate;
 	const char *pvname;
-	char *lv_full_name;
-	uint32_t len;
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
@@ -152,15 +150,9 @@ static int lvchange_availability(struct cmd_context *cmd,
 		}
 
 		if (lv->status & CONVERTING) {
-			len = strlen(lv->vg->name) + strlen(lv->name) + 2;
-			if (!(lv_full_name = alloca(len)))
-				return_0;
-			if (!dm_snprintf(lv_full_name, len, "%s/%s",
-					 lv->vg->name, lv->name))
-				return_0;
 			log_verbose("Spawning background lvconvert process for %s",
 				    lv->name);
-			lvconvert_poll(cmd, lv_full_name, 1);
+			lvconvert_poll(cmd, lv, 1);
 		}
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f1186cf..c5e63a3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -234,14 +234,16 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	return 1;
 }
 
-
 static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
-					      const char *lv_name)
+					      const char *lv_name, const char *uuid)
 {
 	dev_close_all();
 
+	/*
+	 * uuid is here LV uuid, but vg_read will use only first part.
+	 */
         return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-				NULL, LCK_VG_WRITE,
+				uuid, LCK_VG_WRITE,
  				CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
 }
@@ -249,9 +251,15 @@ static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
 						struct volume_group *vg,
 						const char *name,
+						const char *uuid,
 						uint32_t lv_type __attribute((unused)))
 {
-	return find_lv(vg, name);
+	struct logical_volume *lv = find_lv(vg, name);
+
+	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
+		return NULL;
+
+	return lv;
 }
 
 static int _update_lvconvert_mirror(struct cmd_context *cmd __attribute((unused)),
@@ -315,11 +323,24 @@ static struct poll_functions _lvconvert_mirror_fns = {
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
-int lvconvert_poll(struct cmd_context *cmd, const char *lv_name,
+int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
-	return poll_daemon(cmd, lv_name, background, 0, &_lvconvert_mirror_fns,
-			   "Converted");
+	int len = strlen(lv->vg->name) + strlen(lv->name) + 2;
+	char *uuid = alloca(sizeof(lv->lvid));
+	char *lv_full_name = alloca(len);
+
+
+	if (!uuid || !lv_full_name)
+		return_0;
+
+	if (!dm_snprintf(lv_full_name, len, "%s/%s", lv->vg->name, lv->name))
+		return_0;
+
+	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
+
+	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+			   &_lvconvert_mirror_fns, "Converted");
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
@@ -883,7 +904,7 @@ bad:
 			log_print("Conversion starts after activation");
 			goto out;
 		}
-		ret = lvconvert_poll(cmd, lp.lv_name_full,
+		ret = lvconvert_poll(cmd, lvl->lv,
 				     lp.wait_completion ? 0 : 1U);
 	}
 out:
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 7684d33..d491970 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -129,7 +129,7 @@ static int _check_mirror_status(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name,
+static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, const char *uuid,
 				   struct daemon_parms *parms)
 {
 	struct volume_group *vg;
@@ -147,13 +147,13 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name,
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name))) {
+		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
 		}
 
-		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name,
+		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
 							     parms->lv_type))) {
 			log_error("ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
@@ -225,7 +225,8 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 	}
 }
 
-int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
+int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
+		unsigned background,
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
@@ -260,7 +261,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
 	}
 
 	if (name) {
-		if (!_wait_for_single_mirror(cmd, name, &parms))
+		if (!_wait_for_single_mirror(cmd, name, uuid, &parms))
 			return ECMD_FAILED;
 	} else
 		_poll_for_all_vgs(cmd, &parms);
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index 169313f..ba23b18 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -21,10 +21,12 @@
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (struct logical_volume *lv_mirr);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
-					     const char *name);
+					     const char *name,
+					     const char *uuid);
 	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
 					       struct volume_group *vg,
 					       const char *name,
+					       const char *uuid,
 					       uint32_t lv_type);
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
@@ -47,7 +49,8 @@ struct daemon_parms {
 	struct poll_functions *poll_fns;
 };
 
-int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
+int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
+		unsigned background,
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title);
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 9ece646..3d376e6 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -551,7 +551,7 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 }
 
 static struct volume_group *_get_move_vg(struct cmd_context *cmd,
-					 const char *name)
+					 const char *name, const char *uuid)
 {
 	struct physical_volume *pv;
 
@@ -576,7 +576,7 @@ static struct poll_functions _pvmove_fns = {
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		unsigned background)
 {
-	return poll_daemon(cmd, pv_name, background, PVMOVE, &_pvmove_fns,
+	return poll_daemon(cmd, pv_name, NULL, background, PVMOVE, &_pvmove_fns,
 			   "Moved");
 }
 
diff --git a/tools/tools.h b/tools/tools.h
index 36e6f3a..3afa1a1 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -168,6 +168,6 @@ int arg_count_increment(struct cmd_context *cmd, int a);
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
-int lvconvert_poll(struct cmd_context *cmd, const char *lv_name, unsigned background);
+int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned background);
 
 #endif



