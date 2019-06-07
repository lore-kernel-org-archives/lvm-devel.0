From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:47 -0400
Subject: master - vgck --updatemetadata is a new command
Message-ID: <201906072108.x57L8l1Q005329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47effdc025384cef5b3235a9c4b90e7fd74d68a4
Commit:        47effdc025384cef5b3235a9c4b90e7fd74d68a4
Parent:        de3d3b11f493a89ebee2eab7efae70d33face954
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 13:39:41 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

vgck --updatemetadata is a new command

uses vg_write to correct more common or less severe issues,
and also adds the ability to repair some metadata corruption
that couldn't be handled previously.
---
 lib/format_text/text_label.c     |    3 +
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   83 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h          |    1 +
 tools/args.h                     |    3 +
 tools/command-lines.in           |    5 ++
 tools/commands.h                 |    2 +-
 tools/vgck.c                     |   54 ++++++++++++++++++++++++
 8 files changed, 152 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 42184de..1702934 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -341,6 +341,9 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 		goto fail;
 	}
 
+	if (mda)
+		mda->header_start = mdah->start;
+
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 	if (mda_is_ignored(mda)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 219c784..3af8906 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1381,4 +1381,6 @@ int lv_on_pmem(struct logical_volume *lv);
 
 int vg_is_foreign(struct volume_group *vg);
 
+void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 804d0cf..5eabfa6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5597,3 +5597,86 @@ int vg_is_foreign(struct volume_group *vg)
 	return _is_foreign_vg(vg);
 }
 
+void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct dm_list bad_mda_list;
+	struct mda_list *mdal;
+	struct metadata_area *mda;
+	struct device *dev;
+
+	dm_list_init(&bad_mda_list);
+
+	lvmcache_get_bad_mdas(cmd, vg->name, (const char *)&vg->id, &bad_mda_list);
+
+	dm_list_iterate_items(mdal, &bad_mda_list) {
+		mda = mdal->mda;
+		dev = mda_get_device(mda);
+
+		/*
+		 * bad_fields:
+		 *
+		 * 0: shouldn't happen
+		 *
+		 * READ|INTERNAL: there's probably nothing wrong on disk
+		 *
+		 * MAGIC|START: there's a good chance that we were
+		 * reading the mda_header from the wrong location; maybe
+		 * the pv_header location was wrong.  We don't want to
+		 * write new metadata to the wrong location.  To handle
+		 * this we would want to do some further verification that
+		 * we have the mda location correct.
+		 *
+		 * VERSION|CHECKSUM: when the others are correct these
+		 * look safe to repair.
+		 *
+		 * HEADER: general error related to header, covered by fields
+		 * above.
+		 *
+		 * TEXT: general error related to text metadata, we can repair.
+		 */
+		if (!mda->bad_fields ||
+		    (mda->bad_fields & BAD_MDA_READ) ||
+		    (mda->bad_fields & BAD_MDA_INTERNAL) ||
+		    (mda->bad_fields & BAD_MDA_MAGIC) ||
+		    (mda->bad_fields & BAD_MDA_START)) {
+			log_warn("WARNING: not repairing bad metadata (0x%x) for mda%d on %s",
+				 mda->bad_fields, mda->mda_num, dev_name(dev));
+			continue;
+		}
+
+		/*
+		 * vg_write/vg_commit reread the mda_header which checks the
+		 * mda header fields and fails if any are bad, which stops
+		 * vg_write/vg_commit from continuing.  Suppress these header
+		 * field checks when we know the field is bad and we are going
+		 * to replace it.  FIXME: do vg_write/vg_commit really need to
+		 * reread and recheck the mda_header again (probably not)?
+		 */
+
+		if (mda->bad_fields & BAD_MDA_CHECKSUM)
+			mda->ignore_bad_fields |= BAD_MDA_CHECKSUM;
+		if (mda->bad_fields & BAD_MDA_VERSION)
+			mda->ignore_bad_fields |= BAD_MDA_VERSION;
+
+		log_warn("WARNING: repairing bad metadata (0x%x) in mda%d at %llu on %s.",
+			 mda->bad_fields, mda->mda_num, (unsigned long long)mda->header_start, dev_name(dev));
+
+		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
+			log_warn("WARNING: failed to write VG %s metadata to bad mda%d at %llu on %s.",
+				 vg->name, mda->mda_num, (unsigned long long)mda->header_start, dev_name(dev));
+			continue;
+		}
+
+		if (!mda->ops->vg_precommit(vg->fid, vg, mda)) {
+			log_warn("WARNING: failed to precommit VG %s metadata to bad mda%d at %llu on %s.",
+				 vg->name, mda->mda_num, (unsigned long long)mda->header_start, dev_name(dev));
+			continue;
+		}
+
+		if (!mda->ops->vg_commit(vg->fid, vg, mda)) {
+			log_warn("WARNING: failed to commit VG %s metadata to bad mda%d at %llu on %s.",
+				 vg->name, mda->mda_num, (unsigned long long)mda->header_start, dev_name(dev));
+			continue;
+		}
+	}
+}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6d158fe..63ee4a6 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -185,6 +185,7 @@ struct metadata_area {
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
 	uint32_t status;
+	uint64_t header_start; /* mda_header.start */
 	int mda_num;
 	uint32_t bad_fields; /* BAD_MDA_ flags are set to indicate errors found when reading */
 	uint32_t ignore_bad_fields; /* BAD_MDA_ flags are set to indicate errors to ignore */
diff --git a/tools/args.h b/tools/args.h
index 69f7e07..e972c7d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1393,6 +1393,9 @@ arg(thin_ARG, 'T', "thin", 0, 0, 0,
     "See --type thin, --type thin-pool, and --virtualsize.\n"
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n")
 
+arg(updatemetadata_ARG, '\0', "updatemetadata", 0, 0, 0,
+    "Update VG metadata to correct problems.\n")
+
 arg(uuid_ARG, 'u', "uuid", 0, 0, 0,
     "#pvchange\n"
     "Generate new random UUID for specified PVs.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 03dbf57..4601239 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1624,6 +1624,11 @@ vgck
 OO: --reportformat ReportFmt
 OP: VG|Tag ...
 ID: vgck_general
+DESC: Read and display information about a VG.
+
+vgck --updatemetadata VG
+ID: vgck_update_metadata
+DESC: Rewrite VG metadata to correct problems.
 
 ---
 
diff --git a/tools/commands.h b/tools/commands.h
index 612182b..4006fab 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -177,7 +177,7 @@ xx(vgchange,
 
 xx(vgck,
    "Check the consistency of volume group(s)",
-   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
+   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgconvert,
    "Change volume group metadata format",
diff --git a/tools/vgck.c b/tools/vgck.c
index a126c29..90fc5a3 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -15,6 +15,57 @@
 
 #include "tools.h"
 
+/*
+ * TODO: we cannot yet repair corruption in label_header, pv_header/locations,
+ * or corruption of some mda_header fields.
+ */
+
+static int _update_metadata_single(struct cmd_context *cmd __attribute__((unused)),
+		       const char *vg_name,
+		       struct volume_group *vg,
+		       struct processing_handle *handle __attribute__((unused)))
+{
+
+	/*
+	 * Simply calling vg_write can correct or clean up various things:
+	 * . some mda's have old versions of metdadata 
+	 * . wipe outdated PVs
+	 * . fix pv_header used flag and version
+	 * . strip historical lvs
+	 * . clear missing pv flag on unused PV
+	 */
+	if (!vg_write(vg)) {
+		log_error("Failed to write VG.");
+		return 0;
+	}
+
+	if (!vg_commit(vg)) {
+		log_error("Failed to commit VG.");
+		return 0;
+	}
+
+	/*
+	 * vg_write does not write to "bad" mdas (where "bad" is corrupt, can't
+	 * be processed when reading).  bad mdas are not kept in
+	 * fid->metadata_areas_in_use so vg_read and vg_write ignore them, but
+	 * they are saved in lvmcache.  this gets them from lvmcache and tries
+	 * to write this metadata to them.
+	 */
+	vg_write_commit_bad_mdas(cmd, vg);
+
+	return 1;
+}
+
+static int _update_metadata(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->handles_missing_pvs = 1;
+	cmd->wipe_outdated_pvs = 1;
+	cmd->handles_unknown_segments = 1;
+
+	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, NULL,
+			       &_update_metadata_single);
+}
+
 static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,
 		       struct volume_group *vg,
@@ -37,6 +88,9 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
+	if (arg_is_set(cmd, updatemetadata_ARG))
+		return _update_metadata(cmd, argc, argv);
+
 	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL,
 			       &vgck_single);
 }


