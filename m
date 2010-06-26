From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:49 -0400
Subject: [PATCH 18/38] Update _vg_read and _text_create_text_instance to use fid_add_mda[s].
In-Reply-To: <1277520789-6808-18-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-19-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we are constructing the vg, we may need to adjust the list of
metadata_areas if there are ignored mdas.  At label read time, we
do not read the metadata of ignored mdas, and as a result, they do
not get placed on vg->fid->metadata_areas inside _text_create_text_instance
since lvmcache does not have these areas attached to vginfo->infos.
However, when we're checking the pvids inside _vg_read, after having
read another metadata area from another PV, we do have the opportunity
to update the metadata_area and metadata_areas_ignored lists based
on the read metadata_area.  We need accurate mda lists for the reporting
functions that count the ignored mdas, as well as general correctness
of mda balancing.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   20 +++++++-------------
 lib/metadata/metadata.c       |    6 +++++-
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6428703..01c286e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1892,11 +1892,11 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 {
 	struct format_instance *fid;
 	struct text_fid_context *fidtc;
-	struct metadata_area *mda, *mda_new;
+	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct dir_list *dl;
 	struct raw_list *rl;
-	struct dm_list *dir_list, *raw_list, *mdas;
+	struct dm_list *dir_list, *raw_list;
 	char path[PATH_MAX];
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -1924,7 +1924,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
-		dm_list_add(&fid->metadata_areas, &mda->list);
+		fid_add_mda(fid, mda);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
@@ -1941,7 +1941,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
-			dm_list_add(&fid->metadata_areas, &mda->list);
+			fid_add_mda(fid, mda);
 		}
 
 		raw_list = &((struct mda_lists *) fmt->private)->raws;
@@ -1961,7 +1961,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
-			dm_list_add(&fid->metadata_areas, &mda->list);
+			fid_add_mda(fid, mda);
 		}
 
 		/* Scan PVs in VG for any further MDAs */
@@ -1969,14 +1969,8 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 			goto_out;
 		dm_list_iterate_items(info, &vginfo->infos) {
-			mdas = &info->mdas;
-			dm_list_iterate_items(mda, mdas) {
-				/* FIXME Check it holds this VG */
-				mda_new = mda_copy(fmt->cmd->mem, mda);
-				if (!mda_new)
-					return_NULL;
-				dm_list_add(&fid->metadata_areas, &mda_new->list);
-			}
+			if (!fid_add_mdas(fid, &info->mdas))
+				return_NULL;
 		}
 		/* FIXME Check raw metadata area count - rescan if required */
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 58cd2e3..5ec78f0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2723,7 +2723,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	if (correct_vg) {
 		/*
 		 * If the VG has PVs without mdas, or ignored mdas, they may
-		 * still be orphans in the cache: update the cache state here.
+		 * still be orphans in the cache: update the cache state here,
+		 * and update the metadata lists in the vg.
 		 */
 		if (!inconsistent &&
 		    dm_list_size(&correct_vg->pvs) > dm_list_size(pvids)) {
@@ -2747,6 +2748,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 					inconsistent_pvs = 1;
 					break;
 				}
+				if (dm_list_size(&info->mdas) &&
+				    !fid_add_mdas(fid, &info->mdas))
+					return_NULL;
 			}
 
 			/* If the check passed, let's update VG and recalculate pvids */
-- 
1.6.0.6


