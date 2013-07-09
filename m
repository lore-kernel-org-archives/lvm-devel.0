From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 01:38:22 +0000 (UTC)
Subject: master - pvcreate: remove metadata.h header
Message-ID: <20130709013822.3C89461065@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8adddbf101b362884d62ba066cc72b5ded016f37
Commit:        8adddbf101b362884d62ba066cc72b5ded016f37
Parent:        dd302daf646f680531bf76ab13a9dafd06f63220
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 02:37:56 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 02:37:56 2013 +0100

pvcreate: remove metadata.h header

Files in tools/ should only use metadata-exported.h not metadata.h.
Rename pvcreate_locked to pvcreate_single.
---
 lib/metadata/metadata-exported.h |    6 ++----
 lib/metadata/metadata.c          |   10 ++++------
 lib/metadata/metadata.h          |    4 ++--
 lib/metadata/pv_manip.c          |    6 +++---
 liblvm/lvm_pv.c                  |    2 +-
 tools/pvcreate.c                 |    3 +--
 6 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 412d29c..478337f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -481,10 +481,8 @@ struct lvresize_params {
 	const char *ac_type;
 };
 
-struct physical_volume *pvcreate_single(struct cmd_context *cmd,
-					const char *pv_name,
-					struct pvcreate_params *pp,
-					int write_now);
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		    struct pvcreate_params *pp);
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 
 /*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 96a636c..ca6da86 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -635,7 +635,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 			  "physical volume", pv_name);
 		return 0;
 	} else if (!pv && pp) {
-		if (!(pv = pvcreate_single(vg->cmd, pv_name, pp, 0)))
+		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
 			return_0;
 	}
 	if (!add_pv_to_vg(vg, pv_name, pv, pp)) {
@@ -1487,7 +1487,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
 }
 
 /*
- * pvcreate_single() - initialize a device with PV label and metadata area
+ * pvcreate_vol() - initialize a device with PV label and metadata area
  *
  * Parameters:
  * - pv_name: device path to initialize
@@ -1497,10 +1497,8 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
  * NULL: error
  * struct physical_volume * (non-NULL): handle to physical volume created
  */
-struct physical_volume * pvcreate_single(struct cmd_context *cmd,
-					 const char *pv_name,
-					 struct pvcreate_params *pp,
-					 int write_now)
+struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
+				     struct pvcreate_params *pp, int write_now)
 {
 	struct physical_volume *pv = NULL;
 	struct device *dev;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 364722f..80ad22b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -345,8 +345,8 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 			   void *handle __attribute__((unused)), unsigned force_count,
 			   unsigned prompt);
 
-int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
-					struct pvcreate_params *pp);
+struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
+                                     struct pvcreate_params *pp, int write_now);
 
 /* Manipulate PV structures */
 int pv_add(struct volume_group *vg, struct physical_volume *pv);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 3a3ac09..2b16206 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -786,8 +786,8 @@ out:
 	return r;
 }
 
-int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
-		struct pvcreate_params *pp)
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		    struct pvcreate_params *pp)
 {
 	int r = 0;
 
@@ -796,7 +796,7 @@ int pvcreate_locked(struct cmd_context *cmd, const char *pv_name,
 		return 0;
 	}
 
-	if (!(pvcreate_single(cmd, pv_name, pp, 1)))
+	if (!(pvcreate_vol(cmd, pv_name, pp, 1)))
 		goto_out;
 
 	r = 1;
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index e679b3a..a2e7ef0 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -235,7 +235,7 @@ int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
 
 	pp.size = size_sectors;
 
-	if (!pvcreate_locked(cmd, pv_name, &pp))
+	if (!pvcreate_single(cmd, pv_name, &pp))
 		return -1;
 
 	return 0;
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 38642f6..cbd1a59 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -15,7 +15,6 @@
 
 #include "tools.h"
 #include "metadata-exported.h"
-#include "metadata.h"
 
 /*
  * Intial sanity checking of recovery-related command-line arguments.
@@ -113,7 +112,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
-		if (!pvcreate_locked(cmd, argv[i], &pp))
+		if (!pvcreate_single(cmd, argv[i], &pp))
 			ret = ECMD_FAILED;
 	}
 


