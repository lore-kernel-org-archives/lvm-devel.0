From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:29 +0000 (UTC)
Subject: master - vgreduce: Move _vgreduce_single functionality
Message-ID: <20131119205629.04BEF60CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe474e1452866476b7f17175d92417d6d827ae4c
Commit:        fe474e1452866476b7f17175d92417d6d827ae4c
Parent:        20ffb0f721e72fb25905e9ae77689e901babf4ce
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 3 17:31:45 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:28 2013 -0600

vgreduce: Move _vgreduce_single functionality

Moving the core functionality of vgreduce single into
lib/metadata/vg.c so that the command line and lvm2app library
can call the same core functionality.  New function is
vgreduce_single.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 ++
 lib/metadata/vg.c                |   87 ++++++++++++++++++++++++++++++++++++++
 tools/vgreduce.c                 |   81 ++---------------------------------
 3 files changed, 95 insertions(+), 77 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1bf5236..cac5b3c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -592,6 +592,10 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, const char *pv_name);
+
+int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
+			    struct physical_volume *pv);
+
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 476292e..20b4b4d 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -19,6 +19,7 @@
 #include "activate.h"
 #include "toolcontext.h"
 #include "lvmcache.h"
+#include "archiver.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -573,3 +574,89 @@ char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 	repstr[5] = (vg_is_clustered(vg)) ? 'c' : '-';
 	return repstr;
 }
+
+int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
+			    struct physical_volume *pv)
+{
+	struct pv_list *pvl;
+	struct volume_group *orphan_vg = NULL;
+	int r = 0;
+	const char *name = pv_dev_name(pv);
+
+	if (!vg) {
+		log_error(INTERNAL_ERROR "VG is NULL.");
+		return r;
+	}
+
+	if (pv_pe_alloc_count(pv)) {
+		log_error("Physical volume \"%s\" still in use", name);
+		return r;
+	}
+
+	if (vg->pv_count == 1) {
+		log_error("Can't remove final physical volume \"%s\" from "
+			  "volume group \"%s\"", name, vg->name);
+		return r;
+	}
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return r;
+	}
+
+	pvl = find_pv_in_vg(vg, name);
+
+	if (!archive(vg))
+		goto_bad;
+
+	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
+
+	if (pvl)
+		del_pvl_from_vgs(vg, pvl);
+
+	pv->vg_name = vg->fid->fmt->orphan_vg_name;
+	pv->status = ALLOCATABLE_PV;
+
+	if (!dev_get_size(pv_dev(pv), &pv->size)) {
+		log_error("%s: Couldn't get size.", pv_dev_name(pv));
+		goto bad;
+	}
+
+	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg->extent_count -= pv_pe_count(pv);
+
+	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
+				       NULL, 0);
+
+	if (vg_read_error(orphan_vg))
+		goto bad;
+
+	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
+		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
+			  name, vg->name);
+		goto bad;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Removal of physical volume \"%s\" from "
+			  "\"%s\" failed", name, vg->name);
+		goto bad;
+	}
+
+	if (!pv_write(cmd, pv, 0)) {
+		log_error("Failed to clear metadata from physical "
+			  "volume \"%s\" "
+			  "after removal from \"%s\"", name, vg->name);
+		goto bad;
+	}
+
+	backup(vg);
+
+	log_print_unless_silent("Removed \"%s\" from volume group \"%s\"", name, vg->name);
+	r = 1;
+bad:
+	if (pvl)
+		free_pv_fid(pvl->pv);
+	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
+	return r;
+}
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 8803899..534a4fb 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -125,88 +125,15 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
 {
-	struct pv_list *pvl;
-	struct volume_group *orphan_vg = NULL;
-	int r = ECMD_FAILED;
-	const char *name = pv_dev_name(pv);
-
-	if (!vg) {
-		log_error(INTERNAL_ERROR "VG is NULL.");
-		return ECMD_FAILED;
-	}
+	int r = vgreduce_single(cmd, vg, pv);
 
-	if (pv_pe_alloc_count(pv)) {
-		log_error("Physical volume \"%s\" still in use", name);
-		return ECMD_FAILED;
-	}
-
-	if (vg->pv_count == 1) {
-		log_error("Can't remove final physical volume \"%s\" from "
-			  "volume group \"%s\"", name, vg->name);
+	if (!r)
 		return ECMD_FAILED;
-	}
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
-	pvl = find_pv_in_vg(vg, name);
-
-	if (!archive(vg))
-		goto_bad;
-
-	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
-	if (pvl)
-		del_pvl_from_vgs(vg, pvl);
-
-	pv->vg_name = vg->fid->fmt->orphan_vg_name;
-	pv->status = ALLOCATABLE_PV;
-
-	if (!dev_get_size(pv_dev(pv), &pv->size)) {
-		log_error("%s: Couldn't get size.", pv_dev_name(pv));
-		goto bad;
-	}
-
-	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
-	vg->extent_count -= pv_pe_count(pv);
-
-	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
-				       NULL, 0);
-
-	if (vg_read_error(orphan_vg))
-		goto bad;
-
-	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
-		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
-			  name, vg->name);
-		goto bad;
-	}
-
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		log_error("Removal of physical volume \"%s\" from "
-			  "\"%s\" failed", name, vg->name);
-		goto bad;
-	}
-
-	if (!pv_write(cmd, pv, 0)) {
-		log_error("Failed to clear metadata from physical "
-			  "volume \"%s\" "
-			  "after removal from \"%s\"", name, vg->name);
-		goto bad;
-	}
+	return ECMD_PROCESSED;
+}
 
-	backup(vg);
 
-	log_print_unless_silent("Removed \"%s\" from volume group \"%s\"", name, vg->name);
-	r = ECMD_PROCESSED;
-bad:
-	if (pvl)
-		free_pv_fid(pvl->pv);
-	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
-	return r;
-}
 
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {


