From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:25 +0000 (UTC)
Subject: master - metadata: schedule PV for header rewrite if adding a PV to VG or restoring VG
Message-ID: <20160215120825.954B160DC9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10128c9bd67a027b480e0f0637745f97fb39ecfa
Commit:        10128c9bd67a027b480e0f0637745f97fb39ecfa
Parent:        2950adc2ab67fd14173807164f9829f5f53cd33c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 12 14:49:10 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: schedule PV for header rewrite if adding a PV to VG or restoring VG

When adding PV to VG, we need to rewrite PV header as there's a flip
in PV_EXT_USED flag. The same applies if we're restoring VG from backup.
---
 lib/format_text/archiver.c |   10 ++++++++++
 lib/metadata/metadata.c    |    3 ++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 0efe5c5..56eb1ca 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -335,6 +335,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop
 	struct pv_list *pvl;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
+	struct pv_to_write *pvw;
 	uint32_t tmp;
 
 	/*
@@ -363,6 +364,15 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop
 
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->fmt->features & FMT_PV_FLAGS) {
+			if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+				log_error("pv_to_write allocation for '%s' failed", pv_dev_name(pvl->pv));
+				return 0;
+			}
+			pvw->pv = pvl->pv;
+			dm_list_add(&vg->pvs_to_write, &pvw->list);
+		}
+
 		tmp = vg->extent_size;
 		vg->extent_size = 0;
 		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pvl->pv, vg)) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 981bfbc..9c0423e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -279,7 +279,8 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 			break;
 		}
 
-	if (pv->status & UNLABELLED_PV) {
+	if ((pv->fmt->features & FMT_PV_FLAGS) ||
+	    (pv->status & UNLABELLED_PV)) {
 		if (!(pvw = dm_pool_zalloc(mem, sizeof(*pvw)))) {
 			log_error("pv_to_write allocation for '%s' failed", pv_name);
 			return 0;


