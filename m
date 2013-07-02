From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:23 +0000 (UTC)
Subject: master - lib2app: Added PV create. V2
Message-ID: <20130702192623.9BDDE60CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d6ccded3590b46f214561db38e1ce084b643c13
Commit:        6d6ccded3590b46f214561db38e1ce084b643c13
Parent:        d079411051e8151b61c7614e791215db065c01cb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 3 17:53:21 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

lib2app: Added PV create. V2

V2: Correct call to lock_vol

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.h |    3 +++
 lib/metadata/pv_manip.c |   22 ++++++++++++++++++++++
 liblvm/lvm2app.h        |   10 ++++++++++
 liblvm/lvm_pv.c         |   26 ++++++++++++++++++++++++++
 tools/pvcreate.c        |   11 ++---------
 5 files changed, 63 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 5c0a85b..364722f 100644
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
index 30ccd97..3ec20ef 100644
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
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
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
index 695f5eb..54a67c0 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -572,6 +572,16 @@ struct dm_list *lvm_list_pvs(lvm_t libh);
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
index bced4f9..9069f6f 100644
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
index 7570c52..d2de4d9 100644
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
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
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


