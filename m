From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 5 Oct 2017 21:21:34 -0400
Subject: master - vgmerge: Fix intermediate metadata corruption
Message-ID: <201710060121.v961LYRu009702@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=486ed108481cfbe4336f0fa590cbae251188ecc6
Commit:        486ed108481cfbe4336f0fa590cbae251188ecc6
Parent:        a781b1c1788461595f382918bb1fc210d248d444
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 6 02:12:42 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 6 02:20:45 2017 +0100

vgmerge: Fix intermediate metadata corruption

vgmerge suffers from a similar problem to the one fixed in commit
8146548d25e9104f0d530d943290d448c1994c0a ("vgsplit: Fix intermediate
metadata corruption.")

When merging, splitting or renaming VGs, use a new PV status flag
PV_MOVED_VG to mark the PVs that hold metadata with the old VG name and
use this to provide PV-level granularity instead of incorrectly assuming
all PVs in the VG are the same.
---
 WHATS_NEW                        |    3 ++-
 lib/format_text/flags.c          |    1 +
 lib/format_text/format-text.c    |   15 +++++++++------
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/metadata.c          |    6 ++++++
 tools/vgmerge.c                  |    5 +++++
 6 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0cdd398..bba813d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,8 @@
 Version 2.02.175 - 
 ======================================
   Use --help with blockdev when checking for --getsize64 support in fsadm.
-  Fix metadata corruption in vgsplit intermediate state.
+  Fix metadata corruption in vgsplit and vgmerge intermediate states.
+  Add PV_MOVED_VG PV status flag to mark PVs moving between VGs.
   Require LV name with pvmove in a shared VG.
   Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
   Support lvconvert --repair with cache and cachepool volumes.
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 156d542..51acc46 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -48,6 +48,7 @@ static const struct flag _pv_flags[] = {
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{MISSING_PV, "MISSING", COMPATIBLE_FLAG},
 	{MISSING_PV, "MISSING", STATUS_FLAG},
+	{PV_MOVED_VG, NULL, 0},
 	{UNLABELLED_PV, NULL, 0},
 	{0, NULL, 0}
 };
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c359c8a..3e1ca19 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -609,14 +609,17 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct mda_header *mdah;
 	struct pv_list *pvl;
 	int r = 0;
-       uint64_t new_wrap = 0, old_wrap = 0, new_end;
+	uint64_t new_wrap = 0, old_wrap = 0, new_end;
 	int found = 0;
 	int noprecommit = 0;
+	const char *old_vg_name = NULL;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
+			if (pvl->pv->status & PV_MOVED_VG)
+				old_vg_name = vg->old_name;
 			break;
 		}
 	}
@@ -630,8 +633,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah,
-			vg->old_name ? vg->old_name : vg->name, &noprecommit);
+	rlocn = _find_vg_rlocn(&mdac->area, mdah, old_vg_name ? : vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
 
 	if (!fidtc->raw_metadata_buf &&
@@ -719,11 +721,14 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	int r = 0;
 	int found = 0;
 	int noprecommit = 0;
+	const char *old_vg_name = NULL;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (pvl->pv->dev == mdac->area.dev) {
 			found = 1;
+			if (pvl->pv->status & PV_MOVED_VG)
+				old_vg_name = vg->old_name;
 			break;
 		}
 	}
@@ -734,9 +739,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah,
-				     vg->old_name ? vg->old_name : vg->name,
-				     &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, old_vg_name ? : vg->name, &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 92b38de..4a8c519 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -84,6 +84,7 @@
 #define CONVERTING		UINT64_C(0x0000000000400000)	/* LV */
 
 #define MISSING_PV		UINT64_C(0x0000000000800000)	/* PV */
+#define PV_MOVED_VG		UINT64_C(0x4000000000000000)	/* PV - Moved to a new VG */
 #define PARTIAL_LV		UINT64_C(0x0000000001000000)	/* LV - derived flag, not
 							   written out in metadata*/
 
@@ -146,7 +147,7 @@
 #define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
 								   used as SEGTYPE_FLAG to prevent activation on old runtime */
 #define LV_RESHAPE_DATA_OFFSET	UINT64_C(0x2000000000000000)    /* LV reshape flag data offset (out of place reshaping) */
-/* Next unused flag:		UINT64_C(0x4000000000000000)    */
+/* Next unused flag:		UINT64_C(0x8000000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bbbf7d0..c50d579 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -520,6 +520,8 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
+                /* Mark the PVs that still hold metadata with the old VG name */
+                pvl->pv->status |= PV_MOVED_VG;
 	}
 
 	return 1;
@@ -3616,6 +3618,7 @@ static int _vg_commit_mdas(struct volume_group *vg)
 int vg_commit(struct volume_group *vg)
 {
 	int cache_updated = 0;
+	struct pv_list *pvl;
 
 	if (!lvmcache_vgname_is_locked(vg->name)) {
 		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
@@ -3631,11 +3634,14 @@ int vg_commit(struct volume_group *vg)
 		/* Instruct remote nodes to upgrade cached metadata. */
 		if (!remote_commit_cached_metadata(vg))
 			stack; // FIXME: What should we do?
+
 		/*
 		 * We need to clear old_name after a successful commit.
 		 * The volume_group structure could be reused later.
 		 */
 		vg->old_name = NULL;
+	        dm_list_iterate_items(pvl, &vg->pvs)
+			pvl->pv->status &= ~PV_MOVED_VG;
 
 		/* This *is* the original now that it's commited. */
 		release_vg(vg->vg_committed);
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index d49e4e1..86c6a48 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -111,6 +111,8 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		del_pvl_from_vgs(vg_from, pvl);
 		add_pvl_to_vgs(vg_to, pvl);
 		pvl->pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
+		/* Mark the VGs that still hold metadata for the old VG */
+		pvl->pv->status |= PV_MOVED_VG;
 	}
 
 	/* Fix up LVIDs */
@@ -168,6 +170,9 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
+	/* Flag up that some PVs have moved from another VG */
+	vg_to->old_name = vg_from->name;
+
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg_to) || !vg_commit(vg_to))


