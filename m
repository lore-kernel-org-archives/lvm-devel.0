From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 12:50:43 -0400
Subject: master - pvck: new dump option to extract metadata
Message-ID: <201905231650.x4NGohVS026223@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52586b1039a0c1d273676416ba074cadde308bc4
Commit:        52586b1039a0c1d273676416ba074cadde308bc4
Parent:        1022b88a66dd02e981e738719e17452cd5c1bd59
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 22 14:25:08 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 11:49:06 2019 -0500

pvck: new dump option to extract metadata

The new command 'pvck --dump metadata PV' will extract
the current version of VG metadata from a PV for testing
and debugging.  --dump metadata_area extracts the entire
text metadata area.
---
 lib/cache/lvmcache.c          |   31 ++++++
 lib/cache/lvmcache.h          |    5 +
 lib/format_text/format-text.c |  218 +++++++++++++++++++++++++++++++++++++++++
 lib/format_text/format-text.h |   14 +++
 man/pvck.8_des                |    9 ++-
 tools/args.h                  |    5 +
 tools/command-lines.in        |    6 +
 tools/commands.h              |    2 +-
 tools/pvck.c                  |   99 ++++++++++++++++++-
 9 files changed, 386 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7d0c60d..a4037a5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2301,3 +2301,34 @@ int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid)
 	}
 	return 0;
 }
+
+struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
+				       const char *vgname,
+				       struct device *dev,
+				       int use_mda_num)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+
+	if (!use_mda_num)
+		use_mda_num = 1;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
+		return NULL;
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (info->dev != dev)
+			continue;
+
+		dm_list_iterate_items(mda, &info->mdas) {
+			if ((use_mda_num == 1) && (mda->status & MDA_PRIMARY))
+				return mda;
+			if ((use_mda_num == 2) && !(mda->status & MDA_PRIMARY))
+				return mda;
+		}
+		return NULL;
+	}
+	return NULL;
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 26e0953..5e59b94 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -168,6 +168,11 @@ unsigned lvmcache_mda_count(struct lvmcache_info *info);
 int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
+struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
+                                      const char *vgname,
+                                      struct device *dev,
+                                      int use_mda_num);
+
 int lvmcache_found_duplicate_pvs(void);
 int lvmcache_found_duplicate_vgnames(void);
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3828d5f..abf8afc 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2602,3 +2602,221 @@ bad:
 
 	return NULL;
 }
+
+static char *_read_metadata_text(struct cmd_context *cmd, struct device *dev,
+				 uint64_t area_start, uint64_t area_size,
+				 uint32_t *len, uint64_t *disk_offset)
+{
+	struct mda_header *mh;
+	struct raw_locn *rlocn_slot0;
+	uint64_t text_offset, text_size;
+	char *area_buf;
+	char *text_buf;
+
+	/*
+	 * Read the entire metadata area, including mda_header and entire
+	 * circular buffer.
+	 */
+	if (!(area_buf = malloc(area_size)))
+		return_NULL;
+
+	if (!dev_read_bytes(dev, area_start, area_size, area_buf)) {
+		log_error("Failed to read device %s at %llu size %llu",
+			  dev_name(dev),
+			  (unsigned long long)area_start,
+			  (unsigned long long)area_size);
+		return NULL;
+	}
+
+	mh = (struct mda_header *)area_buf;
+	_xlate_mdah(mh);
+
+	rlocn_slot0 = &mh->raw_locns[0];
+	text_offset = rlocn_slot0->offset;
+	text_size = rlocn_slot0->size;
+
+	/*
+	 * Copy and return the current metadata text out of the metadata area.
+	 */
+
+	if (!(text_buf = malloc(text_size)))
+		return_NULL;
+
+	memcpy(text_buf, area_buf + text_offset, text_size);
+
+	if (len)
+		*len = (uint32_t)text_size;
+	if (disk_offset)
+		*disk_offset = area_start + text_offset;
+
+	free(area_buf);
+
+	return text_buf;
+}
+
+int dump_metadata_text(struct cmd_context *cmd,
+		       const char *vgname,
+		       const char *vgid,
+		       struct device *dev,
+		       struct metadata_area *mda,
+		       const char *tofile)
+{
+	char *textbuf;
+	struct format_instance *fid;
+	struct format_instance_ctx fic;
+	struct mda_context *mdac;
+	struct volume_group *vg;
+	unsigned use_previous_vg = 0;
+	uint32_t textlen = 0;
+	uint32_t textcrc;
+	uint64_t text_disk_offset;
+	int ret = 0;
+
+	/*
+	 * Set up overhead/abstractions for reading a given vgname
+	 * (fmt/fid/fic/vgid).
+	 */
+
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vgname;
+	fic.context.vg_ref.vg_id = vgid;
+
+	if (!(fid = _text_create_text_instance(cmd->fmt, &fic))) {
+		log_error("Failed to create format instance");
+		return 0;
+	}
+
+	mdac = mda->metadata_locn;
+
+	/*
+	 * Read the VG metadata from the device as a raw chunk of original text.
+	 */
+	textbuf = _read_metadata_text(cmd, dev,
+				      mdac->area.start, mdac->area.size,
+				      &textlen, &text_disk_offset);
+	if (!textbuf || !textlen) {
+		log_error("No metadata text found on %s", dev_name(dev));
+		_text_destroy_instance(fid);
+		return 0;
+	}
+
+	textcrc = calc_crc(INITIAL_CRC, (uint8_t *)textbuf, textlen);
+
+	/*
+	 * Read the same VG metadata, but imported/parsed into a vg struct
+	 * format so we know it's valid/parsable, and can look at values in it.
+	 */
+	if (!(vg = _vg_read_raw(fid, vgname, mda, NULL, &use_previous_vg))) {
+		log_warn("WARNING: parse error for metadata on %s.", dev_name(dev));
+		_text_destroy_instance(fid);
+	}
+
+	log_print("Metadata for %s from %s at %llu size %u with seqno %u checksum 0x%x.",
+		  vgname, dev_name(dev),
+		  (unsigned long long)text_disk_offset, textlen,
+		  vg ? vg->seqno : 0, textcrc);
+
+	if (!tofile) {
+		log_print("---");
+		printf("%s\n", textbuf);
+		log_print("---");
+	} else {
+		FILE *fp;
+		if (!(fp = fopen(tofile, "wx"))) {
+			log_error("Failed to create file %s", tofile);
+			goto out;
+		}
+
+		fprintf(fp, "%s", textbuf);
+
+		if (fflush(fp))
+			stack;
+		if (fclose(fp))
+			stack;
+	}
+
+	if (vg)
+		release_vg(vg);
+
+	free(textbuf);
+	ret = 1;
+out:
+	return ret;
+}
+
+static char *_read_metadata_area(struct cmd_context *cmd, struct device *dev,
+				 uint64_t area_start, uint64_t area_size)
+{
+	char *area_buf;
+
+	/*
+	 * Read the entire metadata area, including mda_header and entire
+	 * circular buffer.
+	 */
+	if (!(area_buf = malloc(area_size)))
+		return_NULL;
+
+	if (!dev_read_bytes(dev, area_start, area_size, area_buf)) {
+		log_error("Failed to read device %s at %llu size %llu",
+			  dev_name(dev),
+			  (unsigned long long)area_start,
+			  (unsigned long long)area_size);
+		return NULL;
+	}
+
+	return area_buf;
+}
+
+int dump_metadata_area(struct cmd_context *cmd,
+		       const char *vgname,
+		       const char *vgid,
+		       struct device *dev,
+		       struct metadata_area *mda,
+		       const char *tofile)
+{
+	char *areabuf;
+	char *textbuf;
+	struct mda_context *mdac;
+	int ret = 0;
+
+	mdac = mda->metadata_locn;
+
+	areabuf = _read_metadata_area(cmd, dev,
+				      mdac->area.start, mdac->area.size);
+	if (!areabuf) {
+		log_error("No metadata area found on %s", dev_name(dev));
+		return 0;
+	}
+
+	log_print("Metadata buffer for %s from %s in area at %llu size %llu offset 512.",
+		  vgname, dev_name(dev),
+		  (unsigned long long)mdac->area.start,
+		  (unsigned long long)mdac->area.size);
+
+	/* text starts after mda_header which uses 512 bytes */
+	textbuf = areabuf + 512;
+
+	if (!tofile) {
+		/* N.B. this will often include unprintable data */
+		log_print("---");
+		fwrite(textbuf, mdac->area.size - 512, 1, stdout);
+		log_print("---");
+	} else {
+		FILE *fp;
+		if (!(fp = fopen(tofile, "wx"))) {
+			log_error("Failed to create file %s", tofile);
+			goto out;
+		}
+
+		fwrite(textbuf, mdac->area.size - 512, 1, fp);
+
+		if (fflush(fp))
+			stack;
+		if (fclose(fp))
+			stack;
+	}
+	ret = 1;
+out:
+	free(areabuf);
+	return ret;
+}
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 1300e58..6be237b 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -76,4 +76,18 @@ struct data_area_list {
 	struct disk_locn disk_locn;
 };
 
+int dump_metadata_text(struct cmd_context *cmd,
+                       const char *vgname,
+                       const char *vgid,
+                       struct device *dev,
+                       struct metadata_area *mda,
+                       const char *tofile);
+
+int dump_metadata_area(struct cmd_context *cmd,
+                       const char *vgname,
+                       const char *vgid,
+                       struct device *dev,
+                       struct metadata_area *mda,
+                       const char *tofile);
+
 #endif
diff --git a/man/pvck.8_des b/man/pvck.8_des
index 0a32657..fb826d3 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -1 +1,8 @@
-pvck checks the LVM metadata for consistency on PVs.
+pvck checks LVM metadata on PVs.
+
+Use the --dump option to extract metadata from PVs for debugging.
+With dump, set --pvmetadatacopies 2 to extract metadata from a
+second metadata area at the end of the device. Use the --file
+option to save the raw metadata to a specified file. (The raw
+metadata is not usable with vgcfgbackup and vgcfgrestore.)
+
diff --git a/tools/args.h b/tools/args.h
index 3d72e8a..c1efdd6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -213,6 +213,11 @@ arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0,
     "If set to no, the command will not attempt to use device-mapper.\n"
     "For testing and debugging.\n")
 
+arg(dump_ARG, '\0', "dump", string_VAL, 0, 0,
+    "Dump metadata from a PV. Option values include \\fBmetadata\\fP\n"
+    "to extract the current text metadata, and \\fBmetadata_area\\fP\n"
+    "to extract the entire text metadata area.\n")
+
 arg(errorwhenfull_ARG, '\0', "errorwhenfull", bool_VAL, 0, 0,
     "Specifies thin pool behavior when data space is exhausted.\n"
     "When yes, device-mapper will immediately return an error\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0de3de7..0d97348 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1427,6 +1427,12 @@ ID: pvresize_general
 pvck PV ...
 OO: --labelsector Number
 ID: pvck_general
+DESC: Check for metadata on a device
+
+pvck --dump String PV
+OO: --file String, --pvmetadatacopies MetadataCopiesPV
+ID: pvck_dumpmetadata
+DESC: Dump raw metadata from a device
 
 ---
 
diff --git a/tools/commands.h b/tools/commands.h
index 83e50e7..612182b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -114,7 +114,7 @@ xx(pvresize,
    0)
 
 xx(pvck,
-   "Check the consistency of physical volume(s)",
+   "Check metadata on physical volumes",
    LOCKD_VG_SH)
 
 xx(pvcreate,
diff --git a/tools/pvck.c b/tools/pvck.c
index ce74036..15c7e6d 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -15,17 +15,115 @@
 
 #include "base/memory/zalloc.h"
 #include "tools.h"
+#include "lib/format_text/format-text.h"
+
+/*
+ * TODO: option to dump all copies of metadata that are found
+ *
+ * TODO: option to intelligently search for mda locations on
+ * disk in case the pv_header and/or mda_header are damaged.
+ */
+
+static int _dump_metadata(struct cmd_context *cmd, int argc, char **argv, int full_area)
+{
+	struct dm_list devs;
+	struct device_list *devl;
+	struct device *dev;
+	const char *pv_name;
+	const char *vgname;
+	const char *vgid;
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	const char *tofile = NULL;
+	int mda_num = 1;
+	int ret;
+
+	dm_list_init(&devs);
+
+	if (arg_is_set(cmd, file_ARG)) {
+		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
+			return ECMD_FAILED;
+	}
+
+	/* 1: dump metadata from first mda, 2: dump metadata from second mda */
+	if (arg_is_set(cmd, pvmetadatacopies_ARG))
+		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
+
+	pv_name = argv[0];
+
+	if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
+		log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+		return ECMD_FAILED;
+	}
+
+	if (!(devl = zalloc(sizeof(*devl))))
+		return ECMD_FAILED;
+
+	devl->dev = dev;
+	dm_list_add(&devs, &devl->list);
+
+	label_scan_setup_bcache();
+	label_scan_devs(cmd, cmd->filter, &devs);
+
+	if (!dev->pvid[0]) {
+		log_error("No PV ID found for %s", dev_name(dev));
+		return ECMD_FAILED;
+	}
+
+	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
+		log_error("No VG info found for %s", dev_name(dev));
+		return ECMD_FAILED;
+	}
+
+	if (!(vgname = lvmcache_vgname_from_info(info))) {
+		log_error("No VG name found for %s", dev_name(dev));
+		return ECMD_FAILED;
+	}
+
+        if (!(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
+		log_error("No VG ID found for %s", dev_name(dev));
+		return ECMD_FAILED;
+        }
+
+	if (!(mda = lvmcache_get_mda(cmd, vgname, dev, mda_num))) {
+		log_error("No mda %d found for %s", mda_num, dev_name(dev));
+		return ECMD_FAILED;
+	}
+
+	if (full_area)
+		ret = dump_metadata_area(cmd, vgname, vgid, dev, mda, tofile);
+	else
+		ret = dump_metadata_text(cmd, vgname, vgid, dev, mda, tofile);
+
+	if (!ret)
+		return ECMD_FAILED;
+	return ECMD_PROCESSED;
+}
 
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_list devs;
 	struct device_list *devl;
 	struct device *dev;
+	const char *dump;
 	const char *pv_name;
 	uint64_t labelsector;
 	int i;
 	int ret_max = ECMD_PROCESSED;
 
+	if (arg_is_set(cmd, dump_ARG)) {
+		dump = arg_str_value(cmd, dump_ARG, NULL);
+
+		if (!strcmp(dump, "metadata"))
+			return _dump_metadata(cmd, argc, argv, 0);
+
+		if (!strcmp(dump, "metadata_area"))
+			return _dump_metadata(cmd, argc, argv, 1);
+
+		log_error("Unknown dump value.");
+		return ECMD_FAILED;
+	}
+
 	labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
 	dm_list_init(&devs);
@@ -53,7 +151,6 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	label_scan_devs(cmd, cmd->filter, &devs);
 
 	dm_list_iterate_items(devl, &devs) {
-
 		/*
 		 * The scan above will populate lvmcache with any info from the
 		 * standard locations at the start of the device.  Now populate


