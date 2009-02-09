From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:02 -0500
Subject: [PATCH 14/21] Add lvm_errno(), lvm_strerror, lvm_vg_mode.
In-Reply-To: <1234153329-2829-14-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-15-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create struct lib_context to store lvm_errno field as well as cmd_context.
Add 'mode' field to struct volume_group.
Create error APIs - lvm_errno, lvm_strerror.
Update lvm_vg_open to set lvm_errno if invalid mode given (mode != O_RDONLY).
Move lvm_vg_open, lvm_vg_close to lvm2.c (b/c lib_context defined there).
Update test code to use lvm_strerror().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c                       |   97 ++++++++++++++++++++++++++++++++------
 lib/lvm2.h                       |   13 +++++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   25 ----------
 test/api/test.c                  |   20 ++++++--
 5 files changed, 111 insertions(+), 45 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index d880902..cf4e603 100644
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
+	}
+
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
 	}
 
-	return (lvm_handle_t) cmd;
+	return libh;
 }
 
 
 void lvm_destroy(lvm_handle_t libh)
 {
-	destroy_toolcontext((struct cmd_context *)libh);
+	destroy_toolcontext(libh->cmd);
+	dm_free(libh);
 	/* no error handling here */
 }
 
diff --git a/lib/lvm2.h b/lib/lvm2.h
index f0fe0a3..e555291 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -83,6 +83,16 @@ int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list);
 int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
 			  struct dm_report_field_value_type *value);
 
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
 
@@ -141,4 +151,7 @@ int lvm_pv_obj_get_attr_value(lvm_pv_obj_t *obj, const char *attr_name,
 			      struct dm_report_field_value_type *value);
 
 
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
index d6ecf67..dcc0156 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2471,31 +2471,6 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	return vg;
 }
 
-/*
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
 struct dm_list *lvm_pvs_in_vg(vg_t *vg)
 {
 	return (&vg->pvs);
diff --git a/test/api/test.c b/test/api/test.c
index e7137f0..681c9a8 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -62,7 +62,7 @@ static void _show_help(void)
 	       "List the VGs that are currently open\n");
 	printf("'vgs': "
 	       "List all VGs known to the system\n");
-	printf("'vg_open vgname': "
+	printf("'vg_open vgname ['r' | 'w']': "
 	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
 	printf("'vg_close vgname': "
 	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
@@ -214,6 +214,7 @@ static void _vg_open(char **argv, int argc, lvm_handle_t libh)
 	struct lvm_lv_list *lvl;
 	struct dm_list *pvs;
 	struct lvm_pv_list *pvl;
+	mode_t mode;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
@@ -223,9 +224,14 @@ static void _vg_open(char **argv, int argc, lvm_handle_t libh)
 		printf ("VG already open\n");
 		return;
 	}
-	vg = lvm_vg_open(libh, argv[1], O_RDONLY);
-	if (vg_read_error(vg)) {
-		printf("Error opening vg %s\n", argv[1]);
+	if ((argc == 3) && (argv[2][0] == 'w')) {
+		mode = O_RDWR;
+	} else
+		mode = O_RDONLY;
+	vg = lvm_vg_open(libh, argv[1], mode);
+	if (!vg) {
+		printf("Error opening %s: %s\n", argv[1],
+		       lvm_strerror(libh));
 		return;
 	}
 
@@ -267,8 +273,10 @@ static void _vg_close(char **argv, int argc)
 
 static void _show_one_vg(vg_t *vg)
 {
-	/* FIXME: store / display actual open mode */
-	printf("%s: mode = READ\n", lvm_vg_name(vg));
+	printf("%s: mode = %s\n", lvm_vg_name(vg),
+	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
+	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
+	       "UNKNOWN");
 }
 static void _list_open_vgs(void)
 {
-- 
1.6.0.5


