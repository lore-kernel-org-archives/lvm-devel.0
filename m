From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:37 -0500
Subject: [PATCH 08/12] Add lvm_errno(), lvm_strerror, lvm_vg_mode.
In-Reply-To: <1234467041-21522-8-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create struct lib_context to store lvm_errno field as well as cmd_context.
Move lvm_vg_open, lvm_vg_close to lvm2.c (b/c lib_context defined there).
Add 'mode' field to struct volume_group.
Create error APIs - lvm_errno, lvm_strerror.
Update lvm_vg_open to set lvm_errno if invalid mode given (mode != O_RDONLY).
Add lvm-types.h to lvm2.h file.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c                       |   98 ++++++++++++++++++++++++++++++++-----
 lib/lvm2.h                       |   15 ++++++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   25 ----------
 4 files changed, 100 insertions(+), 39 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index d4d3637..f48b451 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -12,6 +12,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <errno.h>
+#include <string.h>
 #include "lvm2.h"
 #include "lib.h"
 #include "toolcontext.h"
@@ -19,10 +21,70 @@
 #include "metadata-exported.h"
 #include "report.h"
 
+struct lib_context {
+	struct cmd_context *cmd;
+	int lvm_errno;
+};
+
+mode_t lvm_vg_mode(vg_t *vg)
+{
+	return vg->mode;
+}
+
+int lvm_errno(lvm_handle_t libh)
+{
+	return libh->lvm_errno;
+}
+
+char *lvm_strerror(lvm_handle_t libh)
+{
+	return strerror(libh->lvm_errno);
+}
+
+/*
+ * Open / read a VG.
+ * FIXME: Only read access allowed.
+ */
+vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
+{
+	vg_t *vg;
+
+	if ((mode & O_ACCMODE) != O_RDONLY) {
+		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
+			  mode);
+		libh->lvm_errno = EPERM;
+		return NULL;
+	}
+	vg = vg_read(libh->cmd, vg_name, NULL, 0);
+
+	if (vg_read_error(vg)) {
+		/* FIXME: fill in vg->errno */
+		return NULL;
+	}
+	vg->mode = mode;
+	return vg;
+}
+
+/*
+ * Close a VG handle.
+ * If lock is still held, unlock the VG.
+ * FIXME: We cannot free the memory as it's tied to the cmd->mem pool.
+ */
+void lvm_vg_close(vg_t *vg)
+{
+	if (vgname_is_locked(vg->name))
+		unlock_vg(vg->cmd, vg->name);
+}
 
 lvm_handle_t lvm_create(const char *system_dir)
 {
 	struct cmd_context *cmd;
+	struct lib_context *libh;
+
+	if (!(libh = dm_malloc(sizeof(*libh)))) {
+		log_error("Failed to allocate library context");
+		return NULL;
+	}
 
 	/* To be done:
 	 * logging bound to handle
@@ -32,27 +94,34 @@ lvm_handle_t lvm_create(const char *system_dir)
 	cmd = create_toolcontext(1, system_dir);
 
 	/* initilize remaining */
-	if (cmd) {
-		/* initilization from lvm_run_command */
-		init_error_message_produced(0);
-		sigint_clear();
-
-		/* FIXME: locking_type config option needed? */
-		/* initialize locking */
-		if (! init_locking(-1, cmd)) {
-			printf("Locking initialisation failed.");
-			lvm_destroy((lvm_handle_t) cmd);
-			return NULL;
-		}
+	if (!cmd) {
+		dm_free(libh);
+		return NULL;
 	}
 
-	return (lvm_handle_t) cmd;
+	libh->cmd = cmd;
+
+	/* initilization from lvm_run_command */
+	init_error_message_produced(0);
+	sigint_clear();
+
+	/* FIXME: locking_type config option needed? */
+	/* initialize locking */
+	if (! init_locking(-1, cmd)) {
+		printf("Locking initialisation failed.");
+		lvm_destroy(libh);
+		dm_free(libh);
+		return NULL;
+	}
+
+	return libh;
 }
 
 
 void lvm_destroy(lvm_handle_t libh)
 {
-	destroy_toolcontext((struct cmd_context *)libh);
+	destroy_toolcontext(libh->cmd);
+	dm_free(libh);
 	/* no error handling here */
 }
 
@@ -61,3 +130,4 @@ int lvm_reload_config(lvm_handle_t libh)
 {
 	return refresh_toolcontext((struct cmd_context *)libh);
 }
+
diff --git a/lib/lvm2.h b/lib/lvm2.h
index 85014f5..d957db9 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -17,6 +17,7 @@
 
 #include <stdint.h>
 #include <fcntl.h>
+#include "lvm-types.h" /* needed for str_list */
 
 /*
  * lvm_handle_t
@@ -77,6 +78,20 @@ const char *lvm_pv_name(const pv_t *pv);
 const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
 
+/*
+ * Open volume group 'vg_name' for reading or writing.
+ *
+ * Returns:
+ * NULL - failure; use liblvm error APIs for specifics
+ * non-NULL - success; VG handle (vg_t *) returned may be used in future calls.
+ *
+ * liblvm error code explanations:
+ * EPERM: Invalid access mode given.
+ */
 vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode);
 void lvm_vg_close(vg_t *vg);
+
+int lvm_errno(lvm_handle_t libh);
+char *lvm_strerror(lvm_handle_t libh);
+mode_t lvm_vg_mode(vg_t *vg);
 #endif
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 257bf91..3063abb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -212,6 +212,7 @@ struct volume_group {
 	struct id id;
 	char *name;
 	char *system_id;
+	mode_t mode;
 
 	uint32_t status;
 	alloc_policy_t alloc;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0fa5db4..4c9f939 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2472,31 +2472,6 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 }
 
 /*
- * Open / read a VG.
- * FIXME: Only read access allowed.
- */
-vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
-{
-	if ((mode & O_ACCMODE) != O_RDONLY) {
-		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
-			mode);
-		return NULL;
-	}
-	return vg_read((struct cmd_context *)libh, vg_name, NULL, 0);
-}
-
-/*
- * Close a VG handle.
- * If lock is still held, unlock the VG.
- * FIXME: We cannot free the memory as it's tied to the cmd->mem pool.
- */
-void lvm_vg_close(vg_t *vg)
-{
-	if (vgname_is_locked(vg->name))
-		unlock_vg(vg->cmd, vg->name);
-}
-
-/*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
  */
-- 
1.6.0.6


