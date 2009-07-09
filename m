From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 18:17:47 -0400
Subject: [PATCH 2/4] Remove force parameter from vg_remove_single, now the liblvm function.
In-Reply-To: <1247177869-12526-2-git-send-email-dwysocha@redhat.com>
References: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
	<1247177869-12526-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1247177869-12526-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move check for active LVs outside of library function.  The vgremove
liblvm function function will fail if there are active LVs.  It will
be the application's responsibility to check this condition and remove
the LVs individually before calling vgremove.  Note also that we've
duplicated the EXPORTED_VG check in vgremove_single (tools) and
vg_remove_single (library).  Duplication seemed the only option here
since we don't want to do the automatic removal of LVs (in the tools)
if the vg is exported, and we still need to protect the library call
from removal if the vg is exported.

We still need to deal with the ORPHAN lock but vg_remove_single is now
very close to our liblvm function.

TODO: Refactor lvremove in a similar way.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    6 +++++-
 lib/metadata/metadata.c          |   23 ++++-------------------
 tools/vgremove.c                 |   24 +++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6e085d8..f4a2170 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -425,7 +425,7 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove(struct volume_group *vg);
-int vg_remove_single(vg_t *vg, force_t force);
+int vg_remove_single(vg_t *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
@@ -436,6 +436,10 @@ int vg_set_alloc_policy(vg_t *vg, alloc_policy_t alloc);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
+/* FIXME: refactor / unexport when lvremove liblvm refactoring dones */
+int remove_lvs_in_vg(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     force_t force);
 /*
  * vg_release() must be called on every struct volume_group allocated
  * by vg_create() or vg_read_internal() to free it when no longer required.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 71cb6ea..5257801 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -343,9 +343,9 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-static int remove_lvs_in_vg(struct cmd_context *cmd,
-			    struct volume_group *vg,
-			    force_t force)
+int remove_lvs_in_vg(struct cmd_context *cmd,
+		     struct volume_group *vg,
+		     force_t force)
 {
 	struct dm_list *lst;
 	struct lv_list *lvl;
@@ -359,7 +359,7 @@ static int remove_lvs_in_vg(struct cmd_context *cmd,
 	return 1;
 }
 
-int vg_remove_single(vg_t *vg, force_t force)
+int vg_remove_single(vg_t *vg)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -382,21 +382,6 @@ int vg_remove_single(vg_t *vg, force_t force)
 	lv_count = vg_visible_lvs(vg);
 
 	if (lv_count) {
-		if ((force == PROMPT) &&
-		    (yes_no_prompt("Do you really want to remove volume "
-				   "group \"%s\" containing %u "
-				   "logical volumes? [y/n]: ",
-				   vg_name, lv_count) == 'n')) {
-			log_print("Volume group \"%s\" not removed", vg_name);
-			return 0;
-		}
-		if (!remove_lvs_in_vg(cmd, vg, force))
-			return 0;
-	}
-
-	lv_count = vg_visible_lvs(vg);
-
-	if (lv_count) {
 		log_error("Volume group \"%s\" still contains %u "
 			  "logical volume(s)", vg_name, lv_count);
 		return 0;
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 8977ea5..1bfff1e 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -19,7 +19,29 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(vg, arg_count(cmd, force_ARG)))
+	unsigned lv_count;
+	force_t force;
+
+	if (!vg_check_status(vg, EXPORTED_VG))
+		return ECMD_FAILED;
+
+	lv_count = vg_visible_lvs(vg);
+
+	force = arg_count(cmd, force_ARG);
+	if (lv_count) {
+		if ((force == PROMPT) &&
+		    (yes_no_prompt("Do you really want to remove volume "
+				   "group \"%s\" containing %u "
+				   "logical volumes? [y/n]: ",
+				   vg_name, lv_count) == 'n')) {
+			log_print("Volume group \"%s\" not removed", vg_name);
+			return ECMD_FAILED;
+		}
+		if (!remove_lvs_in_vg(cmd, vg, force))
+			return ECMD_FAILED;
+	}
+
+	if (!vg_remove_single(vg))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
-- 
1.6.0.6


