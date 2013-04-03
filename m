From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  3 Apr 2013 16:56:10 -0500
Subject: [PATCH 3/4] lib2app: Added PV create.
In-Reply-To: <1365026171-12944-1-git-send-email-tasleson@redhat.com>
References: <1365026171-12944-1-git-send-email-tasleson@redhat.com>
Message-ID: <1365026171-12944-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.h |  3 +++
 lib/metadata/pv_manip.c | 22 ++++++++++++++++++++++
 liblvm/lvm2app.h        | 10 ++++++++++
 liblvm/lvm_pv.c         | 26 ++++++++++++++++++++++++++
 tools/pvcreate.c        | 11 ++---------
 5 files changed, 63 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 35be923..bf4399f 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -345,6 +345,9 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 			   void *handle __attribute__((unused)), unsigned force_count,
 			   unsigned prompt);
 
+int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
+					struct pvcreate_params *pp);
+
 /* Manipulate PV structures */
 int pv_add(struct volume_group *vg, struct physical_volume *pv);
 int pv_remove(struct volume_group *vg, struct physical_volume *pv);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 3823f76..894cf58 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -20,6 +20,8 @@
 #include "locking.h"
 #include "defaults.h"
 #include "lvmetad.h"
+#include "display.h"
+#include "label.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -672,3 +674,23 @@ out:
 
 	return ret;
 }
+
+int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
+		struct pvcreate_params *pp)
+{
+	int ret = ECMD_PROCESSED;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
+	if (!(pvcreate_single(cmd, pv_name, pp, 1))) {
+		stack;
+		ret = ECMD_FAILED;
+	}
+
+	unlock_vg(cmd, VG_ORPHANS);
+
+	return ret;
+}
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 5fe41ac..f889f2f 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -563,6 +563,16 @@ struct dm_list *lvm_list_pvs(lvm_t libh);
 int lvm_list_pvs_free(struct dm_list *pvlist);
 
 /**
+ *  Create a physical volume.
+ *  \param	libh	Library handle
+ *  \param	pv_name	The physical volume name
+ *  \param	size	Size of physical volume, 0 = use all available.
+ *  \return
+ *  0 on success, else -1 with library errno and text set.
+ */
+int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size);
+
+/**
  *  Remove a physical volume.
  *  Note: You cannot remove a PV while iterating through the list of PVs as
  *  locks are held for the PV list.
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 6010f62..a148126 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -226,3 +226,29 @@ int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 		return 0;
 	}
 }
+
+int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
+{
+	int rc = -1;
+	struct pvcreate_params pp;
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	uint64_t size_sectors = size;
+
+	pvcreate_params_set_defaults(&pp);
+
+	if (size_sectors != 0 ) {
+		if( size_sectors % SECTOR_SIZE ) {
+			log_errno(EINVAL, "Size not a multiple of 512");
+					return -1;
+		}
+		size_sectors = size_sectors >> SECTOR_SHIFT;
+	}
+
+	pp.size = size_sectors;
+
+	if (ECMD_PROCESSED == pvcreate_locked(cmd, pv_name, &pp)) {
+		rc = 0;
+	}
+
+	return rc;
+}
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index da51eec..18ce077 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include "metadata-exported.h"
+#include "metadata.h"
 
 /*
  * Intial sanity checking of recovery-related command-line arguments.
@@ -96,7 +97,6 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	int i;
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
-	struct physical_volume *pv;
 
 	pvcreate_params_set_defaults(&pp);
 
@@ -108,19 +108,12 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	for (i = 0; i < argc; i++) {
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphan PVs");
-			return ECMD_FAILED;
-		}
-
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
-		if (!(pv = pvcreate_single(cmd, argv[i], &pp, 1))) {
-			stack;
+		if (ECMD_PROCESSED != pvcreate_locked(cmd, argv[i], &pp)) {
 			ret = ECMD_FAILED;
 		}
 
-		unlock_vg(cmd, VG_ORPHANS);
 		if (sigint_caught())
 			return ret;
 	}
-- 
1.8.1.4


