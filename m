From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:09:10 -0400
Subject: master - improve reading and repairing vg metadata
Message-ID: <201906072109.x57L9Agl005366@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba7ff96faff052c6145c71222ea5047a6bcee33b
Commit:        ba7ff96faff052c6145c71222ea5047a6bcee33b
Parent:        015b906069a989552c09f61d7230b000d0a1f0f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 24 12:04:37 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

improve reading and repairing vg metadata

The fact that vg repair is implemented as a part of vg read
has led to a messy and complicated implementation of vg_read,
and limited and uncontrolled repair capability.  This splits
read and repair apart.

Summary
-------

- take all kinds of various repairs out of vg_read
- vg_read no longer writes anything
- vg_read now simply reads and returns vg metadata
- vg_read ignores bad or old copies of metadata
- vg_read proceeds with a single good copy of metadata
- improve error checks and handling when reading
- keep track of bad (corrupt) copies of metadata in lvmcache
- keep track of old (seqno) copies of metadata in lvmcache
- keep track of outdated PVs in lvmcache
- vg_write will do basic repairs
- new command vgck --updatemetdata will do all repairs

Details
-------

- In scan, do not delete dev from lvmcache if reading/processing fails;
  the dev is still present, and removing it makes it look like the dev
  is not there.  Records are now kept about the problems with each PV
  so they be fixed/repaired in the appropriate places.

- In scan, record a bad mda on failure, and delete the mda from
  mda in use list so it will not be used by vg_read or vg_write,
  only by repair.

- In scan, succeed if any good mda on a device is found, instead of
  failing if any is bad.  The bad/old copies of metadata should not
  interfere with normal usage while good copies can be used.

- In scan, add a record of old mdas in lvmcache for later, do not repair
  them while reading, and do not let them prevent us from finding and
  using a good copy of metadata from elsewhere.  One result is that
  "inconsistent metadata" is no longer a read error, but instead a
  record in lvmcache that can be addressed separate from the read.

- Treat a dev with no good mdas like a dev with no mdas, which is an
  existing case we already handle.

- Don't use a fake vg "handle" for returning an error from vg_read,
  or the vg_read_error function for getting that error number;
  just return null if the vg cannot be read or used, and an error_flags
  arg with flags set for the specific kind of error (which can be used
  later for determining the kind of repair.)

- Saving an original copy of the vg metadata, for purposes of reverting
  a write, is now done explicitly in vg_read instead of being hidden in
  the vg_make_handle function.

- When a vg is not accessible due to "access restrictions" but is
  otherwise fine, return the vg through the new error_vg arg so that
  process_each_pv can skip the PVs in the VG while processing.
  (This is a temporary accomodation for the way process_each_pv
  tracks which devs have been looked at, and can be dropped later
  when process_each_pv implementation dev tracking is changed.)

- vg_read does not try to fix or recover a vg, but now just reads the
  metadata, checks access restrictions and returns it.
  (Checking access restrictions might be better done outside of vg_read,
   but this is a later improvement.)

- _vg_read now simply makes one attempt to read metadata from
  each mda, and uses the most recent copy to return to the caller
  in the form of a 'vg' struct.
  (bad mdas were excluded during the scan and are not retried)
  (old mdas were not excluded during scan and are retried here)

- vg_read uses _vg_read to get the latest copy of metadata from mdas,
  and then makes various checks against it to produce warnings,
  and to check if VG access is allowed (access restrictions include:
  writable, foreign, shared, clustered, missing pvs).

- Things that were previously silently/automatically written by vg_read
  that are now done by vg_write, based on the records made in lvmcache
  during the scan and read:
  . clearing the missing flag
  . updating old copies of metadata
  . clearing outdated pvs
  . updating pv header flags

- Bad/corrupt metadata are now repaired; they were not before.

Test changes
------------

- A read command no longer writes the VG to repair it, so add a write
  command to do a repair.
  (inconsistent-metadata, unlost-pv)

- When a missing PV is removed from a VG, and then the device is
  enabled again, vgck --updatemetadata is needed to clear the
  outdated PV before it can be used again, where it wasn't before.
  (lvconvert-repair-policy, lvconvert-repair-raid, lvconvert-repair,
   mirror-vgreduce-removemissing, pv-ext-flags, unlost-pv)

Reading bad/old metadata
------------------------

- "bad metadata": the mda_header or metadata text has invalid fields
  or can't be parsed by lvm.  This is a form of corruption that would
  not be caused by known failure scenarios.  A checksum error is
  typically included among the errors reported.

- "old metadata": a valid copy of the metadata that has a smaller seqno
  than other copies of the metadata.  This can happen if the device
  failed, or io failed, or lvm failed while commiting new metadata
  to all the metadata areas.  Old metadata on a PV that has been
  removed from the VG is the "outdated" case below.

When a VG has some PVs with bad/old metadata, lvm can simply ignore
the bad/old copies, and use a good copy.  This is why there are
multiple copies of the metadata -- so it's available even when some
of the copies cannot be used.  The bad/old copies do not have to be
repaired before the VG can be used (the repair can happen later.)

A PV with no good copies of the metadata simply falls back to being
treated like a PV with no mdas; a common and harmless configuration.

When bad/old metadata exists, lvm warns the user about it, and
suggests repairing it using a new metadata repair command.
Bad metadata in particular is something that users will want to
investigate and repair themselves, since it should not happen and
may indicate some other problem that needs to be fixed.

PVs with bad/old metadata are not the same as missing devices.
Missing devices will block various kinds of VG modification or
activation, but bad/old metadata will not.

Previously, lvm would attempt to repair bad/old metadata whenever
it was read.  This was unnecessary since lvm does not require every
copy of the metadata to be used.  It would also hide potential
problems that should be investigated by the user.  It was also
dangerous in cases where the VG was on shared storage.  The user
is now allowed to investigate potential problems and decide how
and when to repair them.

Repairing bad/old metadata
--------------------------

When label scan sees bad metadata in an mda, that mda is removed
from the lvmcache info->mdas list.  This means that vg_read will
skip it, and not attempt to read/process it again.  If it was
the only in-use mda on a PV, that PV is treated like a PV with
no mdas.  It also means that vg_write will also skip the bad mda,
and not attempt to write new metadata to it.  The only way to
repair bad metadata is with the metadata repair command.

When label scan sees old metadata in an mda, that mda is kept
in the lvmcache info->mdas list.  This means that vg_read will
read/process it again, and likely see the same mismatch with
the other copies of the metadata.  Like the label_scan, the
vg_read will simply ignore the old copy of the metadata and
use the latest copy.  If the command is modifying the vg
(e.g. lvcreate), then vg_write, which writes new metadata to
every mda on info->mdas, will write the new metadata to the
mda that had the old version.  If successful, this will resolve
the old metadata problem (without needing to run a metadata
repair command.)

Outdated PVs
------------

An outdated PV is a PV that has an old copy of VG metadata
that shows it is a member of the VG, but the latest copy of
the VG metadata does not include this PV.  This happens if
the PV is disconnected, vgreduce --removemissing is run to
remove the PV from the VG, then the PV is reconnected.
In this case, the outdated PV needs have its outdated metadata
removed and the PV used flag needs to be cleared.  This repair
will be done by the subsequent repair command.  It is also done
if vgremove is run on the VG.

MISSING PVs
-----------

When a device is missing, most commands will refuse to modify
the VG.  This is the simple case.  More complicated is when
a command is allowed to modify the VG while it is missing a
device.

When a VG is written while a device is missing for one of it's PVs,
the VG metadata is written to disk with the MISSING flag on the PV
with the missing device.  When the VG is next used, it is treated
as if the PV with the MISSING flag still has a missing device, even
if that device has reappeared.

If all LVs that were using a PV with the MISSING flag are removed
or repaired so that the MISSING PV is no longer used, then the
next time the VG metadata is written, the MISSING flag will be
dropped.

Alternative methods of clearing the MISSING flag are:

vgreduce --removemissing will remove PVs with missing devices,
or PVs with the MISSING flag where the device has reappeared.

vgextend --restoremissing will clear the MISSING flag on PVs
where the device has reappeared, allowing the VG to be used
normally.  This must be done with caution since the reappeared
device may have old data that is inconsistent with data on other PVs.

Bad mda repair
--------------

The new command:
vgck --updatemetadata VG

first uses vg_write to repair old metadata, and other basic
issues mentioned above (old metadata, outdated PVs, pv_header
flags, MISSING_PV flags).  It will also go further and repair
bad metadata:

. text metadata that has a bad checksum
. text metadata that is not parsable
. corrupt mda_header checksum and version fields

(To keep a clean diff, #if 0 is added around functions that
are replaced by new code.  These commented functions are
removed by the following commit.)
---
 lib/cache/lvmcache.c                        |    8 +
 lib/format_text/format-text.c               |    7 +-
 lib/format_text/import.c                    |    6 +-
 lib/format_text/text_label.c                |  207 +++++++--
 lib/label/label.c                           |    4 -
 lib/metadata/metadata-exported.h            |   30 +-
 lib/metadata/metadata.c                     |  628 +++++++++++++++++++++++++-
 lib/metadata/pv.h                           |    1 +
 lib/metadata/vg.c                           |    6 +-
 lib/metadata/vg.h                           |    5 -
 test/shell/inconsistent-metadata.sh         |   49 +--
 test/shell/lvconvert-repair-cache.sh        |    3 +
 test/shell/lvconvert-repair-policy.sh       |    2 +
 test/shell/lvconvert-repair-raid.sh         |    7 +
 test/shell/lvconvert-repair.sh              |    6 +
 test/shell/lvmcache-exercise.sh             |   10 +-
 test/shell/mirror-vgreduce-removemissing.sh |    8 +
 test/shell/pv-ext-flags.sh                  |   34 +-
 test/shell/unlost-pv.sh                     |   52 ++-
 test/shell/vgck.sh                          |    4 +-
 tools/polldaemon.c                          |   17 +-
 tools/toollib.c                             |   73 ++--
 tools/vgcfgbackup.c                         |    8 +-
 tools/vgextend.c                            |   19 +-
 tools/vgsplit.c                             |    7 +-
 25 files changed, 965 insertions(+), 236 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 08c0459..9a3a2e3 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2122,6 +2122,14 @@ int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance
 	return lvmcache_fid_add_mdas(info, fid, info->dev->pvid, ID_LEN);
 }
 
+/*
+ * This is the linkage where information is passed from
+ * the label_scan to vg_read.
+ *
+ * Called by create_text_instance in vg_read to copy the
+ * mda's found during label_scan and saved in info->mdas,
+ * to fid->metadata_areas_in_use which is used by vg_read.
+ */
 int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_instance *fid)
 {
 	struct lvmcache_info *info;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4f0a004..13b2c66 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1357,7 +1357,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	 * valid vg name.
 	 */
 	if (!validate_name(namebuf)) {
-		log_error("Metadata location on %s at %llu begins with invalid VG name.",
+		log_warn("WARNING: Metadata location on %s at %llu begins with invalid VG name.",
 			  dev_name(dev_area->dev),
 			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
@@ -1423,7 +1423,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
 				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
 				vgsummary)) {
-		log_error("Metadata location on %s at %llu has invalid summary for VG.",
+		log_warn("WARNING: metadata on %s at %llu has invalid summary for VG.",
 			  dev_name(dev_area->dev),
 			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
@@ -1431,7 +1431,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(vgsummary->vgname)) {
-		log_error("Metadata location on %s at %llu has invalid VG name.",
+		log_warn("WARNING: metadata on %s at %llu has invalid VG name.",
 			  dev_name(dev_area->dev),
 			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
@@ -2508,3 +2508,4 @@ int text_wipe_outdated_pv_mda(struct cmd_context *cmd, struct device *dev,
 
 	return 1;
 }
+
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 64fbb08..743077b 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -61,13 +61,13 @@ int text_read_metadata_summary(const struct format_type *fmt,
 					 offset2, size2, checksum_fn,
 					 vgsummary->mda_checksum,
 					 checksum_only, 1)) {
-			/* FIXME: handle errors */
-			log_error("Couldn't read volume group metadata from %s.", dev_name(dev));
+			log_warn("WARNING: invalid metadata text from %s at %llu.",
+				 dev_name(dev), (unsigned long long)offset);
 			goto out;
 		}
 	} else {
 		if (!config_file_read(cft)) {
-			log_error("Couldn't read volume group metadata from file.");
+			log_warn("WARNING: invalid metadata text from file.");
 			goto out;
 		}
 	}
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 1702934..934bc73 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -241,12 +241,10 @@ void del_bas(struct dm_list *bas)
 	del_das(bas);
 }
 
-/* FIXME: refactor this function with other mda constructor code */
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored,
 	    struct metadata_area **mda_new)
 {
-/* FIXME List size restricted by pv_header SECTOR_SIZE */
 	struct metadata_area *mdal, *mda;
 	struct mda_lists *mda_lists = (struct mda_lists *) fmt->private;
 	struct mda_context *mdac, *mdac2;
@@ -322,23 +320,22 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 	return 1;
 }
 
-struct _update_mda_baton {
-	struct lvmcache_info *info;
-	struct label *label;
-};
-
-static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
+static int _read_mda_header_and_metadata(const struct format_type *fmt,
+					 struct metadata_area *mda,
+					 struct lvmcache_vgsummary *vgsummary,
+					 uint32_t *bad_fields)
 {
-	struct _update_mda_baton *p = baton;
-	const struct format_type *fmt = p->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	struct lvmcache_vgsummary vgsummary = { 0 };
-	uint32_t bad_fields = 0;
 
-	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda), 0, &bad_fields))) {
-		log_error("Failed to read mda header from %s", dev_name(mdac->area.dev));
-		goto fail;
+	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, (mda->mda_num == 1), 0, bad_fields))) {
+		log_warn("WARNING: bad metadata header on %s at %llu.",
+			 dev_name(mdac->area.dev),
+			 (unsigned long long)mdac->area.start);
+		if (mda)
+			mda->header_start = mdac->area.start;
+		*bad_fields |= BAD_MDA_HEADER;
+		return 0;
 	}
 
 	if (mda)
@@ -350,42 +347,51 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
 				   dev_name(mdac->area.dev),
 				   mdac->area.start);
+		vgsummary->mda_ignored = 1;
 		return 1;
 	}
 
 	if (!read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area,
-					    &vgsummary, &mdac->free_sectors)) {
-		if (vgsummary.zero_offset)
+					    vgsummary, &mdac->free_sectors)) {
+		if (vgsummary->zero_offset)
 			return 1;
 
-		log_error("Failed to read metadata summary from %s", dev_name(mdac->area.dev));
-		goto fail;
-	}
-
-	if (!lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
-		log_error("Failed to save lvm summary for %s", dev_name(mdac->area.dev));
-		goto fail;
+		log_warn("WARNING: bad metadata text on %s in mda%d",
+			 dev_name(mdac->area.dev), mda->mda_num);
+		*bad_fields |= BAD_MDA_TEXT;
+		return 0;
 	}
 
 	return 1;
-
-fail:
-	lvmcache_del(p->info);
-	return 0;
 }
 
+/*
+ * Used by label_scan to get a summary of the VG that exists on this PV.  This
+ * summary is stored in lvmcache vginfo/info/info->mdas and is used later by
+ * vg_read which needs to know which PVs to read for a given VG name, and where
+ * the metadata is at for those PVs.
+ */
+
 static int _text_read(struct labeller *labeller, struct device *dev, void *label_buf,
 		      uint64_t label_sector, int *is_duplicate)
 {
+	struct lvmcache_vgsummary vgsummary;
+	struct lvmcache_info *info;
+	const struct format_type *fmt = labeller->fmt;
 	struct label_header *lh = (struct label_header *) label_buf;
 	struct pv_header *pvhdr;
 	struct pv_header_extension *pvhdr_ext;
-	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	struct metadata_area *mda1 = NULL;
+	struct metadata_area *mda2 = NULL;
 	struct disk_locn *dlocn_xl;
 	uint64_t offset;
 	uint32_t ext_version;
-	struct _update_mda_baton baton;
-	struct label *label;
+	uint32_t bad_fields;
+	int mda_count = 0;
+	int good_mda_count = 0;
+	int bad_mda_count = 0;
+	int rv1, rv2;
 
 	/*
 	 * PV header base
@@ -411,8 +417,6 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 				  FMT_TEXT_ORPHAN_VG_NAME, 0, is_duplicate)))
 		return_0;
 
-	label = lvmcache_get_label(info);
-
 	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
 
 	lvmcache_del_das(info);
@@ -426,11 +430,27 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 		dlocn_xl++;
 	}
 
-	/* Metadata area headers */
 	dlocn_xl++;
+
+	/* Metadata areas */
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		lvmcache_add_mda(info, dev, offset, xlate64(dlocn_xl->size), 0, NULL);
+
+		/*
+		 * This just calls add_mda() above, replacing info with info->mdas.
+		 */
+		lvmcache_add_mda(info, dev, offset, xlate64(dlocn_xl->size), 0, &mda);
+
 		dlocn_xl++;
+		mda_count++;
+
+		if (mda_count == 1) {
+			mda1 = mda;
+			mda1->mda_num = 1;
+		}
+		else if (mda_count == 2) {
+			mda2 = mda;
+			mda2->mda_num = 2;
+		}
 	}
 
 	dlocn_xl++;
@@ -440,7 +460,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 	 */
 	pvhdr_ext = (struct pv_header_extension *) ((char *) dlocn_xl);
 	if (!(ext_version = xlate32(pvhdr_ext->version)))
-		goto out;
+		goto scan_mdas;
 
 	log_debug_metadata("%s: PV header extension version " FMTu32 " found",
 			   dev_name(dev), ext_version);
@@ -457,22 +477,117 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 		lvmcache_add_ba(info, offset, xlate64(dlocn_xl->size));
 		dlocn_xl++;
 	}
-out:
-	baton.info = info;
-	baton.label = label;
+
+ scan_mdas:
+	if (!mda_count) {
+		log_debug_metadata("Scanning %s found no mdas.", dev_name(dev));
+		return 1;
+	}
 
 	/*
-	 * In the vg_read phase, we compare all mdas and decide which to use
-	 * which are bad and need repair.
+	 * Track which devs have bad metadata so repair can find them (even if
+	 * this dev also has good metadata that we are able to use).
 	 *
-	 * FIXME: this quits if the first mda is bad, but we need something
-	 * smarter to be able to use the second mda if it's good.
+	 * When bad metadata is seen, the unusable mda struct is removed from
+	 * lvmcache info->mdas.  This means that vg_read and vg_write will skip
+	 * the bad mda not try to read or write the bad metadata.  The bad mdas
+	 * are saved in a separate bad_mdas list in lvmcache so that repair can
+	 * find them to repair.
 	 */
-	if (!lvmcache_foreach_mda(info, _read_mda_header_and_metadata, &baton)) {
-		log_error("Failed to scan VG from %s", dev_name(dev));
-		return 0;
+
+	if (mda1) {
+		log_debug_metadata("Scanning %s mda1 summary.", dev_name(dev));
+		memset(&vgsummary, 0, sizeof(vgsummary));
+		bad_fields = 0;
+		vgsummary.mda_num = 1;
+
+		rv1 = _read_mda_header_and_metadata(fmt, mda1, &vgsummary, &bad_fields);
+
+		if (rv1 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
+			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+				/* I believe this is only an internal error. */
+				log_warn("WARNING: Scanning %s mda1 failed to save internal summary.", dev_name(dev));
+
+				dm_list_del(&mda1->list);
+				bad_fields |= BAD_MDA_INTERNAL;
+				mda1->bad_fields = bad_fields;
+				lvmcache_save_bad_mda(info, mda1);
+				mda1 = NULL;
+				bad_mda_count++;
+			} else {
+				/* The normal success path */
+				log_debug("Scanned %s mda1 seqno %u", dev_name(dev), vgsummary.seqno);
+				good_mda_count++;
+			}
+		}
+
+		if (!rv1) {
+			/*
+			 * Remove the bad mda from normal mda list so it's not
+			 * used by vg_read/vg_write, but keep track of it in
+			 * lvmcache for repair.
+			 */
+			log_warn("WARNING: scanning %s mda1 failed to read metadata summary.", dev_name(dev));
+			log_warn("WARNING: repair VG metadata on %s with vgck --updatemetadata.", dev_name(dev));
+
+			dm_list_del(&mda1->list);
+			mda1->bad_fields = bad_fields;
+			lvmcache_save_bad_mda(info, mda1);
+			mda1 = NULL;
+			bad_mda_count++;
+		}
 	}
 
+	if (mda2) {
+		log_debug_metadata("Scanning %s mda2 summary.", dev_name(dev));
+		memset(&vgsummary, 0, sizeof(vgsummary));
+		bad_fields = 0;
+		vgsummary.mda_num = 2;
+
+		rv2 = _read_mda_header_and_metadata(fmt, mda2, &vgsummary, &bad_fields);
+
+		if (rv2 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
+			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+				/* I believe this is only an internal error. */
+				log_warn("WARNING: Scanning %s mda2 failed to save internal summary.", dev_name(dev));
+
+				dm_list_del(&mda2->list);
+				bad_fields |= BAD_MDA_INTERNAL;
+				mda2->bad_fields = bad_fields;
+				lvmcache_save_bad_mda(info, mda2);
+				mda2 = NULL;
+				bad_mda_count++;
+			} else {
+				/* The normal success path */
+				log_debug("Scanned %s mda2 seqno %u", dev_name(dev), vgsummary.seqno);
+				good_mda_count++;
+			}
+		}
+
+		if (!rv2) {
+			/*
+			 * Remove the bad mda from normal mda list so it's not
+			 * used by vg_read/vg_write, but keep track of it in
+			 * lvmcache for repair.
+			 */
+			log_warn("WARNING: scanning %s mda2 failed to read metadata summary.", dev_name(dev));
+			log_warn("WARNING: repair VG metadata on %s with vgck --updatemetadata.", dev_name(dev));
+
+			dm_list_del(&mda2->list);
+			mda2->bad_fields = bad_fields;
+			lvmcache_save_bad_mda(info, mda2);
+			mda2 = NULL;
+			bad_mda_count++;
+		}
+	}
+
+	if (good_mda_count)
+		return 1;
+
+	if (bad_mda_count)
+		return 0;
+
+	/* no metadata in the mdas */
 	return 1;
 }
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 4d008ed..a8d87ec 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -432,9 +432,6 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	ret = labeller->ops->read(labeller, dev, label_buf, sector, &is_duplicate);
 
 	if (!ret) {
-		/* FIXME: handle errors */
-		lvmcache_del_dev(dev);
-
 		if (is_duplicate) {
 			/*
 			 * _text_read() called lvmcache_add() which found an
@@ -720,7 +717,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 				scan_failed = 1;
 				scan_process_errors++;
 				scan_failed_count++;
-				lvmcache_del_dev(devl->dev);
 			}
 		}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3af8906..10593a0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -181,15 +181,14 @@
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* vg_read and vg_read_for_update flags */
-#define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_OK_NOTFOUND	0x00040000U
 #define READ_WARN_INCONSISTENT	0x00080000U
 #define READ_FOR_UPDATE		0x00100000U /* A meta-flag, useful with toollib for_each_* functions. */
 #define PROCESS_SKIP_SCAN	 0x00200000U /* skip lvmcache_label_scan in process_each_pv */
 
-/* vg's "read_status" field */
-#define FAILED_INCONSISTENT	0x00000001U
+/* vg_read returns these in error_flags */
+#define FAILED_NOT_ENABLED	0x00000001U
 #define FAILED_LOCKING		0x00000002U
 #define FAILED_NOTFOUND		0x00000004U
 #define FAILED_READ_ONLY	0x00000008U
@@ -202,6 +201,7 @@
 #define FAILED_SYSTEMID		0x00000400U
 #define FAILED_LOCK_TYPE	0x00000800U
 #define FAILED_LOCK_MODE	0x00001000U
+#define FAILED_INTERNAL_ERROR	0x00002000U
 #define SUCCESS			0x00000000U
 
 #define VGMETADATACOPIES_ALL UINT32_MAX
@@ -717,24 +717,14 @@ int lv_resize(struct logical_volume *lv,
 	      struct lvresize_params *lp,
 	      struct dm_list *pvh);
 
-/*
- * Return a handle to VG metadata.
- */
-struct volume_group *vg_read_internal(struct cmd_context *cmd,
-                                      const char *vgname, const char *vgid,
-                                      uint32_t lockd_state, uint32_t warn_flags,
-                                      int enable_repair,
-                                      int *mdas_consistent);
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, uint32_t read_flags, uint32_t lockd_state);
+struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const char *vgid,
+			     uint32_t read_flags, uint32_t lockd_state,
+			     uint32_t *error_flags, struct volume_group **error_vg);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t read_flags, uint32_t lockd_state);
-struct volume_group *vg_read_orphans(struct cmd_context *cmd,
-                                             uint32_t warn_flags,
-                                             const char *orphan_vgname);
-/* 
- * Test validity of a VG handle.
- */
+struct volume_group *vg_read_orphans(struct cmd_context *cmd, const char *orphan_vgname);
+
+/* this is historical and being removed, don't use */
 uint32_t vg_read_error(struct volume_group *vg_handle);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
@@ -757,7 +747,7 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh);
 int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 int vg_validate(struct volume_group *vg);
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
-struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name);
+struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name, int *exists);
 int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
 void vg_remove_pvs(struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2d3ff1c..90409b3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -43,6 +43,46 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct volume_group *vg,
 					struct lvmcache_info *info);
 
+static int _check_pv_ext(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct lvmcache_info *info;
+	uint32_t ext_version, ext_flags;
+	struct pv_list *pvl;
+
+	if (vg_is_foreign(vg))
+		return 1;
+
+	if (vg_is_shared(vg))
+		return 1;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv))
+			continue;
+
+		/* is_missing_pv doesn't catch NULL dev */
+		if (!pvl->pv->dev)
+			continue;
+
+		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, pvl->pv->dev, 0)))
+			continue;
+
+		ext_version = lvmcache_ext_version(info);
+		if (ext_version < PV_HEADER_EXTENSION_VSN) {
+			log_warn("WARNING: PV %s in VG %s is using an old PV header, modify the VG to update.",
+				 dev_name(pvl->pv->dev), vg->name);
+			continue;
+		}
+
+		ext_flags = lvmcache_ext_flags(info);
+		if (!(ext_flags & PV_EXT_USED)) {
+			log_warn("WARNING: PV %s in VG %s is missing the used flag in PV header.",
+				 dev_name(pvl->pv->dev), vg->name);
+		}
+	}
+
+	return 1;
+}
+
 /*
  * Historically, DEFAULT_PVMETADATASIZE was 255 for many years,
  * but that value was only used if default_data_alignment was
@@ -373,6 +413,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	return 1;
 }
 
+#if 0
 static int _copy_pv(struct dm_pool *pvmem,
 		    struct physical_volume *pv_to,
 		    struct physical_volume *pv_from)
@@ -414,6 +455,7 @@ bad:
 	dm_pool_free(pvmem, pvl_to);
 	return NULL;
 }
+#endif
 
 static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 		    const char *pv_name, int enforce_pv_from_source)
@@ -587,7 +629,7 @@ int vg_remove_check(struct volume_group *vg)
 {
 	unsigned lv_count;
 
-	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
+	if (vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
 			  "or has PVs missing.", vg ? vg->name : "");
 		log_error("Consider vgreduce --removemissing if metadata "
@@ -966,6 +1008,7 @@ static int _vg_update_embedded_copy(struct volume_group *vg, struct volume_group
 	return 1;
 }
 
+#if 0
 /*
  * Create a (struct volume_group) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
@@ -995,6 +1038,7 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 
 	return vg;
 }
+#endif
 
 int lv_has_unknown_segments(const struct logical_volume *lv)
 {
@@ -1017,24 +1061,24 @@ int vg_has_unknown_segments(const struct volume_group *vg)
 	return 0;
 }
 
-struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name)
+struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name, int *exists)
 {
 	uint32_t rc;
 	struct volume_group *vg;
 
 	if (!validate_name(vg_name)) {
 		log_error("Invalid vg name %s", vg_name);
-		/* FIXME: use _vg_make_handle() w/proper error code */
 		return NULL;
 	}
 
 	rc = vg_lock_newname(cmd, vg_name);
+	if (rc == FAILED_EXIST)
+		*exists = 1;
 	if (rc != SUCCESS)
-		/* NOTE: let caller decide - this may be check for existence */
-		return _vg_make_handle(cmd, NULL, rc);
+		return NULL;
 
 	vg = vg_create(cmd, vg_name);
-	if (!vg || vg_read_error(vg))
+	if (!vg)
 		unlock_vg(cmd, NULL, vg_name);
 
 	return vg;
@@ -1042,11 +1086,6 @@ struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_
 
 /*
  * Create a VG with default parameters.
- * Returns:
- * - struct volume_group* with SUCCESS code: VG structure created
- * - NULL or struct volume_group* with FAILED_* code: error creating VG structure
- * Use vg_read_error() to determine success or failure.
- * FIXME: cleanup usage of _vg_make_handle()
  */
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
@@ -1087,11 +1126,10 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 			  vg_name);
 		goto bad;
 	}
-	return _vg_make_handle(cmd, vg, SUCCESS);
+	return vg;
 
 bad:
 	unlock_and_release_vg(cmd, vg, vg_name);
-	/* FIXME: use _vg_make_handle() w/proper error code */
 	return NULL;
 }
 
@@ -3216,6 +3254,7 @@ void vg_revert(struct volume_group *vg)
 	}
 }
 
+#if 0
 static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
 {
 	int *in_use = _in_use;
@@ -3223,6 +3262,7 @@ static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
 		*in_use = 1;
 	return 1;
 }
+#endif
 
 struct _vg_read_orphan_baton {
 	struct cmd_context *cmd;
@@ -3395,9 +3435,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 }
 
 /* Make orphan PVs look like a VG. */
-struct volume_group *vg_read_orphans(struct cmd_context *cmd,
-					     uint32_t warn_flags,
-					     const char *orphan_vgname)
+struct volume_group *vg_read_orphans(struct cmd_context *cmd, const char *orphan_vgname)
 {
 	const struct format_type *fmt;
 	struct lvmcache_vginfo *vginfo;
@@ -3458,6 +3496,7 @@ struct volume_group *vg_read_orphans(struct cmd_context *cmd,
 	return vg;
 }
 
+#if 0
 static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
@@ -3491,6 +3530,7 @@ static void _free_pv_list(struct dm_list *all_pvs)
 	dm_list_iterate_items(pvl, all_pvs)
 		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
 }
+#endif
 
 static void _destroy_fid(struct format_instance **fid)
 {
@@ -3511,6 +3551,7 @@ int vg_missing_pv_count(const struct volume_group *vg)
 	return ret;
 }
 
+#if 0
 static int _check_reappeared_pv(struct volume_group *correct_vg,
 				struct physical_volume *pv, int act)
 {
@@ -4177,6 +4218,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	return correct_vg;
 }
+#endif
 
 #define DEV_LIST_DELIM ", "
 
@@ -4266,9 +4308,6 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 	struct device_list *dl;
 	int found_inconsistent = 0;
 
-	if (is_orphan_vg(vg->name))
-		return 1;
-
 	strncpy(vgid, (const char *) vg->id.uuid, sizeof(vgid));
 	vgid[ID_LEN] = '\0';
 
@@ -4316,6 +4355,7 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 	return 1;
 }
 
+#if 0
 struct volume_group *vg_read_internal(struct cmd_context *cmd,
 				      const char *vgname, const char *vgid,
 				      uint32_t lockd_state, uint32_t warn_flags,
@@ -4375,6 +4415,7 @@ out:
 
 	return vg;
 }
+#endif
 
 void free_pv_fid(struct physical_volume *pv)
 {
@@ -4438,7 +4479,7 @@ static void _set_pv_device(struct format_instance *fid,
 			buffer[0] = '\0';
 
 		if (fid->fmt->cmd && !fid->fmt->cmd->pvscan_cache_single)
-			log_error_once("Couldn't find device with uuid %s.", buffer);
+			log_warn("WARNING: Couldn't find device with uuid %s.", buffer);
 		else
 			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
 	}
@@ -4686,6 +4727,7 @@ int vg_check_status(const struct volume_group *vg, uint64_t status)
 	return !vg_bad_status_bits(vg, status);
 }
 
+#if 0
 /*
  * VG is left unlocked on failure
  */
@@ -4727,6 +4769,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 
 	return (struct volume_group *)vg;
 }
+#endif
 
 static int _allow_extra_system_id(struct cmd_context *cmd, const char *system_id)
 {
@@ -4757,9 +4800,6 @@ static int _allow_extra_system_id(struct cmd_context *cmd, const char *system_id
 static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg,
 				uint32_t lockd_state, uint32_t *failure)
 {
-	if (!is_real_vg(vg->name))
-		return 1;
-
 	if (cmd->lockd_vg_disable)
 		return 1;
 
@@ -4905,6 +4945,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	return 0;
 }
 
+#if 0
 /*
  * FIXME: move vg_bad_status_bits() checks in here.
  */
@@ -5108,6 +5149,7 @@ struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_
 
 	return vg;
 }
+#endif
 
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
@@ -5117,7 +5159,7 @@ uint32_t vg_read_error(struct volume_group *vg_handle)
 	if (!vg_handle)
 		return FAILED_ALLOCATION;
 
-	return vg_handle->read_status;
+	return SUCCESS;
 }
 
 /*
@@ -5615,7 +5657,7 @@ int lv_on_pmem(struct logical_volume *lv)
 
 int vg_is_foreign(struct volume_group *vg)
 {
-	return _is_foreign_vg(vg);
+	return vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id);
 }
 
 void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
@@ -5701,3 +5743,539 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 		}
 	}
 }
+
+static struct volume_group *_vg_read(struct cmd_context *cmd,
+				     const char *vgname,
+				     const char *vgid,
+				     unsigned precommitted)
+{
+	const struct format_type *fmt = cmd->fmt;
+	struct format_instance *fid = NULL;
+	struct format_instance_ctx fic;
+	struct volume_group *vg, *vg_ret = NULL;
+	struct metadata_area *mda, *mda2;
+	unsigned use_precommitted = precommitted;
+	struct device *mda_dev, *dev_ret;
+	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
+	int found_old_metadata = 0;
+	unsigned use_previous_vg;
+
+	log_debug_metadata("Reading VG %s %s", vgname ?: "<no name>", vgid ?: "<no vgid>");
+
+	/*
+	 * Rescan the devices that are associated with this vg in lvmcache.
+	 * This repeats what was done by the command's initial label scan,
+	 * but only the devices associated with this VG.
+	 *
+	 * The lvmcache info about these devs is from the initial label scan
+	 * performed by the command before the vg lock was held.  Now the VG
+	 * lock is held, so we rescan all the info from the devs in case
+	 * something changed between the initial scan and now that the lock
+	 * is held.
+	 *
+	 * Some commands (e.g. reporting) are fine reporting data read by
+	 * the label scan.  It doesn't matter if the devs changed between
+	 * the label scan and here, we can report what was seen in the
+	 * scan, even though it is the old state, since we will not be
+	 * making any modifications.  If the VG was being modified during
+	 * the scan, and caused us to see inconsistent metadata on the
+	 * different PVs in the VG, then we do want to rescan the devs
+	 * here to get a consistent view of the VG.  Note that we don't
+	 * know if the scan found all the PVs in the VG at this point.
+	 * We don't know that until vg_read looks at the list of PVs in
+	 * the metadata and compares that to the devices found by the scan.
+	 *
+	 * It's possible that a change made to the VG during scan was
+	 * adding or removing a PV from the VG.  In this case, the list
+	 * of devices associated with the VG in lvmcache would change
+	 * due to the rescan.
+	 *
+	 * The devs in the VG may be persistently inconsistent due to some
+	 * previous problem.  In this case, rescanning the labels here will
+	 * find the same inconsistency.  The VG repair (mistakenly done by
+	 * vg_read below) is supposed to fix that.
+	 *
+	 * FIXME: sort out the usage of the global lock (which is mixed up
+	 * with the orphan lock), and when we can tell that the global
+	 * lock is taken prior to the label scan, and still held here,
+	 * we can also skip the rescan in that case.
+	 */
+	if (!cmd->can_use_one_scan || lvmcache_scan_mismatch(cmd, vgname, vgid)) {
+		log_debug_metadata("Rescanning devices for %s", vgname);
+		lvmcache_label_rescan_vg(cmd, vgname, vgid);
+	} else {
+		log_debug_metadata("Skipped rescanning devices for %s", vgname);
+	}
+
+	/* Now determine the correct vgname if none was supplied */
+	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+		log_debug_metadata("Cache did not find VG name from vgid %s", vgid);
+		return NULL;
+	}
+
+	/* Determine the correct vgid if none was supplied */
+	if (!vgid && !(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
+		log_debug_metadata("Cache did not find VG vgid from name %s", vgname);
+		return NULL;
+	}
+
+	/*
+	 * A "format instance" is an abstraction for a VG location,
+	 * i.e. where a VG's metadata exists on disk.
+	 *
+	 * An fic (format_instance_ctx) is a temporary struct used
+	 * to create an fid (format_instance).  The fid hangs around
+	 * and is used to create a 'vg' to which it connected (vg->fid).
+	 *
+	 * The 'fic' describes a VG in terms of fmt/name/id.
+	 *
+	 * The 'fid' describes a VG in more detail than the fic,
+	 * holding information about where to find the VG metadata.
+	 *
+	 * The 'vg' describes the VG in the most detail representing
+	 * all the VG metadata.
+	 *
+	 * The fic and fid are set up by create_instance() to describe
+	 * the VG location.  This happens before the VG metadata is
+	 * assembled into the more familiar struct volume_group "vg".
+	 *
+	 * The fid has one main purpose: to keep track of the metadata
+	 * locations for a given VG.  It does this by putting 'mda'
+	 * structs on fid->metadata_areas_in_use, which specify where
+	 * metadata is located on disk.  It gets this information
+	 * (metadata locations for a specific VG) from the command's
+	 * initial label scan.  The info is passed indirectly via
+	 * lvmcache info/vginfo structs, which are created by the
+	 * label scan and then copied into fid by create_instance().
+	 *
+	 * FIXME: just use the vginfo/info->mdas lists directly instead
+	 * of copying them into the fid list.
+	 */
+
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vgname;
+	fic.context.vg_ref.vg_id = vgid;
+
+	/*
+	 * Sets up the metadata areas that we need to read below.
+	 * For each info in vginfo->infos, for each mda in info->mdas,
+	 * (found during label_scan), copy the mda to fid->metadata_areas_in_use
+	 */
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
+		log_error("Failed to create format instance");
+		return NULL;
+	}
+
+	/*
+	 * We use the fid globally here so prevent the release_vg
+	 * call to destroy the fid - we may want to reuse it!
+	 */
+	fid->ref_count++;
+
+
+	/*
+	 * label_scan found PVs for this VG and set up lvmcache to describe the
+	 * VG/PVs that we use here to read the VG.  It created 'vginfo' for the
+	 * VG, and created an 'info' attached to vginfo for each PV.  It also
+	 * added a metadata_area struct to info->mdas for each metadata area it
+	 * found on the PV.  The info->mdas structs are copied to
+	 * fid->metadata_areas_in_use by create_instance above, and here we
+	 * read VG metadata from each of those mdas.
+	 */
+	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+		mda_dev = mda_get_device(mda);
+
+		/* I don't think this can happen */
+		if (!mda_dev) {
+			log_warn("Ignoring metadata for VG %s from missing dev.", vgname);
+			continue;
+		}
+
+		use_previous_vg = 0;
+
+		if (use_precommitted) {
+			log_debug_metadata("Reading VG %s precommit metadata from %s %llu",
+				 vgname, dev_name(mda_dev), (unsigned long long)mda->header_start);
+
+			vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
+
+			if (!vg && !use_previous_vg) {
+				log_warn("WARNING: Reading VG %s precommit on %s failed.", vgname, dev_name(mda_dev));
+				vg_fmtdata = NULL;
+				continue;
+			}
+		} else {
+			log_debug_metadata("Reading VG %s metadata from %s %llu",
+				 vgname, dev_name(mda_dev), (unsigned long long)mda->header_start);
+
+			vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
+
+			if (!vg && !use_previous_vg) {
+				log_warn("WARNING: Reading VG %s on %s failed.", vgname, dev_name(mda_dev));
+				vg_fmtdata = NULL;
+				continue;
+			}
+		}
+
+		if (!vg)
+			continue;
+
+		if (vg && !vg_ret) {
+			vg_ret = vg;
+			dev_ret = mda_dev;
+			continue;
+		}
+
+		/* 
+		 * Use the newest copy of the metadata found on any mdas.
+		 * Above, We could check if the scan found an old metadata
+		 * seqno in this mda and just skip reading it again; then these
+		 * seqno checks would just be sanity checks.
+		 */
+
+		if (vg->seqno == vg_ret->seqno) {
+			release_vg(vg);
+			continue;
+		}
+
+		if (vg->seqno > vg_ret->seqno) {
+			log_warn("WARNING: ignoring metadata seqno %u on %s for seqno %u on %s for VG %s.",
+				 vg_ret->seqno, dev_name(dev_ret),
+				 vg->seqno, dev_name(mda_dev), vg->name);
+			found_old_metadata = 1;
+			release_vg(vg_ret);
+			vg_ret = vg;
+			dev_ret = mda_dev;
+			vg_fmtdata = NULL;
+			continue;
+		}
+
+		if (vg_ret->seqno > vg->seqno) {
+			log_warn("WARNING: ignoring metadata seqno %u on %s for seqno %u on %s for VG %s.",
+				 vg->seqno, dev_name(mda_dev),
+				 vg_ret->seqno, dev_name(dev_ret), vg->name);
+			found_old_metadata = 1;
+			release_vg(vg);
+			vg_fmtdata = NULL;
+			continue;
+		}
+	}
+
+	if (found_old_metadata)
+		log_warn("WARNING: Inconsistent metadata found for VG %s", vgname);
+
+	vg = NULL;
+
+	if (vg_ret)
+		set_pv_devices(fid, vg_ret);
+
+	fid->ref_count--;
+
+	if (!vg_ret) {
+		_destroy_fid(&fid);
+		goto_out;
+	}
+
+	/*
+	 * Correct the lvmcache representation of the VG using the metadata
+	 * that we have chosen above (vg_ret).
+	 *
+	 * The vginfo/info representation created by label_scan was not
+	 * entirely correct since it did not use the full or final metadata.
+	 *
+	 * In lvmcache, PVs with no mdas were not attached to the vginfo during
+	 * label_scan because label_scan didn't know where they should go.  Now
+	 * that we have the VG metadata we can tell, so use that to attach those
+	 * info's to the vginfo.
+	 *
+	 * Also, outdated PVs that have been removed from the VG were incorrectly
+	 * attached to the vginfo during label_scan, and now need to be detached.
+	 */
+	lvmcache_update_vg_from_read(vg_ret, vg_ret->status & PRECOMMITTED);
+
+	/*
+	 * lvmcache_update_vg identified outdated mdas that we read above that
+	 * are not actually part of the VG.  Remove those outdated mdas from
+	 * the fid's list of mdas.
+	 */
+	dm_list_iterate_items_safe(mda, mda2, &fid->metadata_areas_in_use) {
+		mda_dev = mda_get_device(mda);
+		if (lvmcache_is_outdated_dev(cmd, vg_ret->name, (const char *)&vg_ret->id, mda_dev)) {
+			log_debug_metadata("vg_read %s ignore mda for outdated dev %s",
+					   vg_ret->name, dev_name(mda_dev));
+			dm_list_del(&mda->list);
+		}
+	}
+
+out:
+	return vg_ret;
+}
+
+struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const char *vgid,
+			     uint32_t read_flags, uint32_t lockd_state,
+			     uint32_t *error_flags, struct volume_group **error_vg)
+{
+	char uuidstr[64] __attribute__((aligned(8)));
+	struct volume_group *vg = NULL;
+	struct lv_list *lvl;
+	struct pv_list *pvl;
+	int missing_pv_dev = 0;
+	int missing_pv_flag = 0;
+	uint32_t failure = 0;
+	int writing = (read_flags & READ_FOR_UPDATE);
+
+	if (is_orphan_vg(vg_name)) {
+		log_very_verbose("Reading orphan VG %s", vg_name);
+		vg = vg_read_orphans(cmd, vg_name);
+		*error_flags = 0;
+		*error_vg = NULL;
+		return vg;
+	}
+
+	if (!validate_name(vg_name)) {
+		log_error("Volume group name \"%s\" has invalid characters.", vg_name);
+		return NULL;
+	}
+
+	if (!lock_vol(cmd, vg_name, writing ? LCK_VG_WRITE : LCK_VG_READ, NULL)) {
+		log_error("Can't get lock for %s", vg_name);
+		failure |= FAILED_LOCKING;
+		goto_bad;
+	}
+
+	if (!(vg = _vg_read(cmd, vg_name, vgid, 0))) {
+		/* Some callers don't care if the VG doesn't exist and don't want an error message. */
+		if (!(read_flags & READ_OK_NOTFOUND))
+			log_error("Volume group \"%s\" not found", vg_name);
+		failure |= FAILED_NOTFOUND;
+		goto_bad;
+	}
+
+	/*
+	 * Check and warn if PV ext info is not in sync with VG metadata
+	 * (vg_write fixes.)
+	 */
+	_check_pv_ext(cmd, vg);
+
+	if (!vg_strip_outdated_historical_lvs(vg))
+		log_warn("WARNING: failed to strip outdated historical lvs.");
+
+	/*
+	 * Check for missing devices in the VG.  In most cases a VG cannot be
+	 * changed while it's missing devices.  This restriction is implemented
+	 * here in vg_read.  Below we return an error from vg_read if the
+	 * vg_read flag indicates that the command is going to modify the VG.
+	 * (We should probably implement this restriction elsewhere instead of
+	 * returning an error from vg_read.)
+	 *
+	 * The PV's device may be present while the PV for the device has the
+	 * MISSING_PV flag set in the metadata.  This happened because the VG
+	 * was written while this dev was missing, so the MISSING flag was
+	 * written in the metadata for PV.  Now the device has reappeared.
+	 * However, the VG has changed since the device was last present, and
+	 * if the device has outdated data it may not be safe to just start
+	 * using it again.
+	 *
+	 * If there were no PE's used on the PV, we can just clear the MISSING
+	 * flag, but if there were PE's used we need to continue to treat the
+	 * PV as if the device is missing, limiting operations like the VG has
+	 * a missing device, and requiring the user to remove the reappeared
+	 * device from the VG, like a missing device, with vgreduce
+	 * --removemissing.
+	 */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!id_write_format(&pvl->pv->id, uuidstr, sizeof(uuidstr)))
+			uuidstr[0] = '\0';
+
+		if (!pvl->pv->dev) {
+			/* The obvious and common case of a missing device. */
+
+			log_warn("WARNING: VG %s is missing PV %s.", vg_name, uuidstr);
+			missing_pv_dev++;
+
+		} else if (pvl->pv->status & MISSING_PV) {
+			/* A device that was missing but has reappeared. */
+
+			if (pvl->pv->pe_alloc_count == 0) {
+				log_warn("WARNING: VG %s has unused reappeared PV %s %s.", vg_name, dev_name(pvl->pv->dev), uuidstr);
+				pvl->pv->status &= ~MISSING_PV;
+				/* tell vgextend restoremissing that MISSING flag was cleared here */
+				pvl->pv->unused_missing_cleared = 1;
+			} else {
+				log_warn("WARNING: VG %s was missing PV %s %s.", vg_name, dev_name(pvl->pv->dev), uuidstr);
+				missing_pv_flag++;
+			}
+		}
+	}
+
+	if (missing_pv_dev || missing_pv_flag)
+		vg_mark_partial_lvs(vg, 1);
+
+	if (!check_pv_segments(vg)) {
+		log_error(INTERNAL_ERROR "PV segments corrupted in %s.", vg->name);
+		failure |= FAILED_INTERNAL_ERROR;
+		goto_bad;
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!check_lv_segments(lvl->lv, 0)) {
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.", lvl->lv->name);
+			failure |= FAILED_INTERNAL_ERROR;
+			goto_bad;
+		}
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		/* Checks that cross-reference other LVs. */
+		if (!check_lv_segments(lvl->lv, 1)) {
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.", lvl->lv->name);
+			failure |= FAILED_INTERNAL_ERROR;
+			goto_bad;
+		}
+	}
+
+	if (!check_pv_dev_sizes(vg))
+		log_warn("WARNING: One or more devices used as PVs in VG %s have changed sizes.", vg->name);
+
+	_check_devs_used_correspond_with_vg(vg);
+
+	if (!_access_vg_lock_type(cmd, vg, lockd_state, &failure)) {
+		/* Either FAILED_LOCK_TYPE or FAILED_LOCK_MODE were set. */
+		goto_bad;
+	}
+
+	if (!_access_vg_systemid(cmd, vg)) {
+		failure |= FAILED_SYSTEMID;
+		goto_bad;
+	}
+
+	if (!_access_vg_clustered(cmd, vg)) {
+		failure |= FAILED_CLUSTERED;
+		goto_bad;
+	}
+
+	if (writing && !(read_flags & READ_ALLOW_EXPORTED) && vg_is_exported(vg)) {
+		log_error("Volume group %s is exported", vg->name);
+		failure |= FAILED_EXPORTED;
+		goto_bad;
+	}
+
+	if (writing && !(vg->status & LVM_WRITE)) {
+		log_error("Volume group %s is read-only", vg->name);
+		failure |= FAILED_READ_ONLY;
+		goto_bad;
+	}
+
+	if (!cmd->handles_missing_pvs && (missing_pv_dev || missing_pv_flag) && writing) {
+		log_error("Cannot change VG %s while PVs are missing.", vg->name);
+		log_error("See vgreduce --removemissing and vgextend --restoremissing.");
+		failure |= FAILED_NOT_ENABLED;
+		goto_bad;
+	}
+
+	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) && writing) {
+		log_error("Cannot change VG %s with unknown segments in it!", vg->name);
+		failure |= FAILED_NOT_ENABLED; /* FIXME new failure code here? */
+		goto_bad;
+	}
+
+	/*
+	 * When we are reading the VG with the intention of writing it,
+	 * we save a second copy of the VG in vg->vg_committed.  This
+	 * copy remains unmodified by the command operation, and is used
+	 * later if there is an error and we want to reactivate LVs.
+	 * FIXME: be specific about exactly when this works correctly.
+	 */
+	if (writing) {
+		struct dm_config_tree *cft;
+
+		if (dm_pool_locked(vg->vgmem)) {
+			/* FIXME: can this happen? */
+			log_warn("WARNING: vg_read no vg copy: pool locked");
+			goto out;
+		}
+
+		if (vg->vg_committed) {
+			/* FIXME: can this happen? */
+			log_warn("WARNING: vg_read no vg copy: copy exists");
+			release_vg(vg->vg_committed);
+			vg->vg_committed = NULL;
+		}
+
+		if (vg->vg_precommitted) {
+			/* FIXME: can this happen? */
+			log_warn("WARNING: vg_read no vg copy: pre copy exists");
+			release_vg(vg->vg_precommitted);
+			vg->vg_precommitted = NULL;
+		}
+
+		if (!(cft = export_vg_to_config_tree(vg))) {
+			log_warn("WARNING: vg_read no vg copy: copy export failed");
+			goto out;
+		}
+
+		if (!(vg->vg_committed = import_vg_from_config_tree(cft, vg->fid)))
+			log_warn("WARNING: vg_read no vg copy: copy import failed");
+
+		dm_config_destroy(cft);
+	} else {
+		if (vg->vg_precommitted)
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", vg, vg->vg_precommitted);
+		if (vg->vg_committed)
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", vg, vg->vg_committed);
+	}
+out:
+	/* We return with the VG lock held when read is successful. */
+	*error_flags = SUCCESS;
+	if (error_vg)
+		*error_vg = NULL;
+	return vg;
+
+bad:
+	*error_flags = failure;
+
+	/*
+	 * FIXME: get rid of this case so we don't have to return the vg when
+	 * there's an error.  It is here for process_each_pv() which wants to
+	 * eliminate the VG's devs from the list of devs it is processing, even
+	 * when it can't access the VG because of wrong system id or similar.
+	 * This could be done by looking at lvmcache info structs intead of 'vg'.
+	 * It's also used by process_each_vg/process_each_lv which want to
+	 * include error_vg values (like system_id) in error messages.
+	 * These values could also be found from lvmcache vginfo.
+	 */
+	if (error_vg && vg) {
+		if (vg->vg_precommitted)
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", vg, vg->vg_precommitted);
+		if (vg->vg_committed)
+			log_error(INTERNAL_ERROR "vg_read vg %p vg_committed %p", vg, vg->vg_committed);
+
+		/* caller must unlock_vg and release_vg */
+		*error_vg = vg;
+		return_NULL;
+	}
+
+	if (vg) {
+		unlock_vg(cmd, vg, vg_name);
+		release_vg(vg);
+	}
+	if (error_vg)
+		*error_vg = NULL;
+	return_NULL;
+}
+
+/*
+ * Simply a version of vg_read() that automatically sets the READ_FOR_UPDATE
+ * flag, which means the caller intends to write the VG after reading it,
+ * so vg_read should acquire an exclusive file lock on the vg.
+ */
+struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
+			 const char *vgid, uint32_t read_flags, uint32_t lockd_state)
+{
+	struct volume_group *vg;
+	uint32_t error_flags = 0;
+
+	vg = vg_read(cmd, vg_name, vgid, read_flags | READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
+
+	return vg;
+}
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index c162acd..3430c2e 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -59,6 +59,7 @@ struct physical_volume {
 
         /* This is true whenever the represented PV has a label associated. */
         uint64_t is_labelled:1;
+        uint64_t unused_missing_cleared:1;
 
         /* NB. label_sector is valid whenever is_labelled is true */
 	uint64_t label_sector;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index aca4fe7..beddf73 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -84,7 +84,7 @@ static void _free_vg(struct volume_group *vg)
 
 void release_vg(struct volume_group *vg)
 {
-	if (!vg || (vg->fid && vg == vg->fid->fmt->orphan_vg))
+	if (!vg || is_orphan_vg(vg->name))
 		return;
 
 	release_vg(vg->vg_committed);
@@ -711,9 +711,9 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->extent_count -= pv_pe_count(pv);
 
 	/* FIXME: we don't need to vg_read the orphan vg here */
-	orphan_vg = vg_read_orphans(cmd, 0, vg->fid->fmt->orphan_vg_name);
+	orphan_vg = vg_read_orphans(cmd, vg->fid->fmt->orphan_vg_name);
 
-	if (vg_read_error(orphan_vg))
+	if (!orphan_vg)
 		goto bad;
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 3fd4756..6e89b33 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -122,11 +122,6 @@ struct volume_group {
 	struct dm_list removed_pvs;
 	uint32_t open_mode; /* FIXME: read or write - check lock type? */
 
-	/*
-	 * Store result of the last vg_read().
-	 * 0 for success else appropriate FAILURE_* bits set.
-	 */
-	uint32_t read_status;
 	uint32_t mda_copies; /* target number of mdas for this VG */
 
 	struct dm_hash_table *hostnames; /* map of creation hostnames */
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index b42715d..e5ccf0c 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -24,53 +24,48 @@ lvchange -a n $vg/mirror
 
 aux backup_dev "${DEVICES[@]}"
 
-init() {
+makeold() {
+	# reset metadata on all devs to starting condition
 	aux restore_dev "${DEVICES[@]}"
 	not check lv_field $vg/resized lv_size "8.00m"
+	# change the metadata on all devs
 	lvresize -L 8192K $vg/resized
+	# reset metadata on just dev1 to the previous version
 	aux restore_dev "$dev1"
 }
 
-init
-vgscan 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgscan 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
-check lv_field $vg/resized lv_size "8.00m"
+# create old metadata
+makeold
 
-# vgdisplay fixes
-init
-vgdisplay $vg 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgdisplay $vg 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
+# reports old metadata
+vgs $vg 2>&1 | tee cmd.out
+grep "ignoring metadata" cmd.out
 check lv_field $vg/resized lv_size "8.00m"
 
-# lvs fixes up
-init
-lvs $vg 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgdisplay $vg 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
-check lv_field $vg/resized lv_size "8.00m"
+# corrects old metadata
+lvcreate -l1 -an $vg
 
-# vgs fixes up as well
-init
+# no old report
 vgs $vg 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg" cmd.out
-vgs $vg 2>&1 | tee cmd.out
-not grep "Inconsistent metadata found for VG $vg" cmd.out
+not grep "ignoring metadata" cmd.out
 check lv_field $vg/resized lv_size "8.00m"
 
-echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
+
+echo Check auto-repair of failed vgextend
+echo - metadata written to original pv but not new pv
+
 vgremove -f $vg
 pvremove -ff "${DEVICES[@]}"
 pvcreate "${DEVICES[@]}"
+
 aux backup_dev "$dev2"
 vgcreate $SHARED $vg "$dev1"
 vgextend $vg "$dev2"
 aux restore_dev "$dev2"
-vgscan
+
+vgs -o+vg_mda_count $vg
+pvs -o+vg_mda_count
+
 should check compare_fields vgs $vg vg_mda_count pvs "$dev2" vg_mda_count
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 348dbaf..49cfbb1 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -93,6 +93,9 @@ lvconvert --yes --uncache $vg/$lv1
 
 aux enable_dev "$dev2"
 
+# vg was changed while dev was missing
+vgextend --restoremissing $vg "$dev2"
+
 # FIXME: temporary workaround
 lvcreate -L1 -n $lv5 $vg
 lvremove -ff $vg
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index f9fca00..b69658e 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -24,6 +24,8 @@ aux lvmconf 'allocation/maximise_cling = 0' \
 cleanup_() {
 	vgreduce --removemissing $vg
 	for d in "$@"; do aux enable_dev "$d"; done
+	# clear the outdated metadata on enabled devs before we can reuse them
+	vgck --updatemetadata $vg
 	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
 	lvcreate -aey --type mirror -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3:0"
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 2f41760..711f386 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -65,6 +65,7 @@ aux disable_dev "$dev2"
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev2"
+vgck --updatemetadata $vg
 vgextend $vg "$dev2"
 lvremove -ff $vg/$lv1
 
@@ -80,6 +81,7 @@ aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev2" "$dev3"
+vgck --updatemetadata $vg
 vgextend $vg "$dev2" "$dev3"
 lvremove -ff $vg/$lv1
 
@@ -96,6 +98,7 @@ aux disable_dev "$dev3"
 vgreduce --removemissing -f $vg
 lvconvert -y --repair $vg/$lv1
 aux enable_dev "$dev3"
+vgck --updatemetadata $vg
 pvcreate -yff "$dev3"
 vgextend $vg "$dev3"
 lvremove -ff $vg/$lv1
@@ -114,6 +117,7 @@ aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
+vgck --updatemetadata $vg
 vgextend $vg "$dev3"
 lvremove -ff $vg/$lv1
 
@@ -128,6 +132,7 @@ aux disable_dev "$dev4" "$dev5"
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev4" "$dev5"
+vgck --updatemetadata $vg
 vgextend $vg "$dev4" "$dev5"
 lvremove -ff $vg/$lv1
 
@@ -145,6 +150,7 @@ aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev4"
+vgck --updatemetadata $vg
 vgextend $vg "$dev4"
 lvremove -ff $vg/$lv1
 
@@ -163,6 +169,7 @@ aux wait_for_sync $vg $lv1
 lvconvert -y --repair $vg/$lv1
 vgreduce --removemissing $vg
 aux enable_dev "$dev4"
+vgck --updatemetadata $vg
 vgextend $vg "$dev4"
 lvremove -ff $vg/$lv1
 
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index ae8fa7e..0d0231e 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -106,17 +106,23 @@ lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
 aux enable_dev "$dev1"
+# clear the outdated dev before we can reuse it
+vgck --updatemetadata $vg
 vgextend $vg "$dev1"
 aux disable_dev "$dev2"
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
 aux enable_dev "$dev2"
+# clear the outdated dev before we can reuse it
+vgck --updatemetadata $vg
 vgextend $vg "$dev2"
 aux disable_dev "$dev3"
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 aux enable_dev "$dev3"
+# clear the outdated dev before we can reuse it
+vgck --updatemetadata $vg
 vgextend $vg "$dev3"
 
 vgremove -ff $vg
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 908cdf8..8cfb7f1 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -43,14 +43,16 @@ pvs "$dev1"
 lvcreate -aey -m2 --type mirror -l4 --alloc anywhere --corelog -n $lv1 $vg2
 
 aux disable_dev "$dev3"
+
+pvs 2>&1| tee out
+grep "is missing PV" out
+
 lvconvert --yes --repair $vg2/$lv1
-aux enable_dev "$dev3"
 
-# here it should fix any reappeared devices
-lvs
+aux enable_dev "$dev3"
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
-not grep reappeared out
+not grep "is missing PV" out
 
 # This removes the first "vg1" using its uuid
 vgremove -ff -S vg_uuid=$UUID1
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index d95a0ac..f2f7c19 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -123,8 +123,16 @@ check_and_cleanup_lvs_()
 recover_vg_()
 {
 	aux enable_dev "$@"
+
+	# clear outdated metadata on PVs so they can be used again
+	vgck --updatemetadata $vg
+
+	pvscan --cache
+
 	pvcreate -ff "$@"
+	# wipefs -a "$@"
 	vgextend $vg "$@"
+
 	check_and_cleanup_lvs_
 }
 
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index bae16df..22e9b3a 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -39,7 +39,6 @@ check pv_field "$dev2" pv_in_use "used"
 # disable $dev2 and dev1 with 0 MDAs remains, but still
 # marked as used, so pvcreate/vgcreate/pvremove should fail
 aux disable_dev "$dev2"
-pvscan --cache
 
 check pv_field "$dev1" pv_in_use "used"
 not pvcreate "$dev1" 2>err
@@ -71,20 +70,14 @@ vgcreate $vg1 "$dev1" "$dev2"
 # disable $dev1, then repair the VG - $dev1 is removed from VG
 aux disable_dev "$dev1"
 vgreduce --removemissing $vg1
-# now, enable $dev1, automatic repair will happen on pvs call
-# (or any other lvm command that does vg_read with repair inside)
-aux enable_dev "$dev1"
 
-# FIXME: once persistent cache does not cause races with timestamps
-#        causing LVM tools to not see the VG inconsistency and once
-#        VG repair is always done, delete this line which removes
-#        persistent .cache as a workaround
-rm -f "$TESTDIR/etc/.cache"
+# now, enable $dev1 and clear the old metadata from it
+aux enable_dev "$dev1"
+vgck --updatemetadata $vg1
 
 vgck $vg1
-# check $dev1 does not contain the PV_EXT_FLAG anymore - it
-# should be removed as part of the repaid during vg_read since
-# $dev1 is not part of $vg1 anymore
+
+# check $dev1 does not contain the PV_EXT_FLAG anymore
 check pv_field "$dev1" pv_in_use ""
 
 #############################################
@@ -105,7 +98,6 @@ check pv_field "$dev2" pv_in_use "used"
 
 pvchange --metadataignore y "$dev1"
 aux disable_dev "$dev2"
-pvscan --cache
 
 check pv_field "$dev1" pv_in_use "used"
 not pvcreate "$dev1" 2>err
@@ -136,20 +128,14 @@ vgcreate $vg1 "$dev1" "$dev2"
 # disable $dev1, then repair the VG - $dev1 is removed from VG
 aux disable_dev "$dev1"
 vgreduce --removemissing $vg1
-# now, enable $dev1, automatic repair will happen on pvs call
-# (or any other lvm command that does vg_read with repair inside)
-aux enable_dev "$dev1"
 
-# FIXME: once persistent cache does not cause races with timestamps
-#        causing LVM tools to not see the VG inconsistency and once
-#        VG repair is always done, delete this line which removes
-#        persistent .cache as a workaround
-rm -f "$TESTDIR/etc/.cache"
+# now, enable $dev1 and clear the old metadata from it
+aux enable_dev "$dev1"
+vgck --updatemetadata $vg1
 
 vgck $vg1
-# check $dev1 does not contain the PV_EXT_FLAG anymore - it
-# should be removed as part of the repaid during vg_read since
-# $dev1 is not part of $vg1 anymore
+
+# check $dev1 does not contain the PV_EXT_FLAG anymore
 check pv_field "$dev1" pv_in_use ""
 
 ###########################
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index edf7f31..50f8928 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -15,47 +15,59 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-check_() {
-	local cache=""
-	# vgscan needs --cache option for direct scan if lvmetad is used
-	test -e LOCAL_LVMETAD && cache="--cache"
-	vgscan $cache 2>&1 | tee vgscan.out
-	"$@" grep "Inconsistent metadata found for VG $vg" vgscan.out
-}
-
 aux prepare_vg 3
 
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
-#lvchange -a n $vg
 
 # try orphaning a missing PV (bz45867)
 aux disable_dev "$dev1"
 vgreduce --removemissing --force $vg
 aux enable_dev "$dev1"
 
-check_
-test -e LOCAL_LVMETAD && pvcreate -f "$dev1"
-check_ not
+vgscan 2>&1 | tee vgscan.out
+grep "Inconsistent metadata found for VG $vg" vgscan.out
+
+# erase outdated dev1
+vgck --updatemetadata $vg
+
+vgscan 2>&1 | tee vgscan.out
+not grep "Inconsistent metadata found for VG $vg" vgscan.out
+
 
-# try to just change metadata; we expect the new version (with MISSING_PV set
-# on the reappeared volume) to be written out to the previously missing PV
 vgextend $vg "$dev1"
+
 lvcreate -l 1 -n boo -a n --zero n $vg
+
 aux disable_dev "$dev1"
+
 lvremove $vg/mirror
+
 aux enable_dev "$dev1"
-check_
-test -e LOCAL_LVMETAD && lvremove $vg/boo # FIXME trigger a write :-(
-check_ not
+
+vgscan 2>&1 | tee vgscan.out
+grep "Inconsistent metadata found for VG $vg" vgscan.out
+
+# write the vg to update the metadata on dev1
+vgck --updatemetadata $vg
+
+vgscan 2>&1 | tee vgscan.out
+not grep "Inconsistent metadata found for VG $vg" vgscan.out
 
 aux disable_dev "$dev1"
+
 vgreduce --removemissing --force $vg
+
 aux enable_dev "$dev1"
 
 vgscan 2>&1 | tee out
-grep 'Removing PV' out
 
-vgs 2>&1 | tee out
-not grep 'Removing PV' out
+vgscan 2>&1 | tee vgscan.out
+grep "Inconsistent metadata found for VG $vg" vgscan.out
+
+# erase outdated dev1
+vgck --updatemetadata $vg
+
+vgscan 2>&1 | tee vgscan.out
+not grep "Inconsistent metadata found for VG $vg" vgscan.out
 
 vgremove -ff $vg
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 3288d1b..b6c2cba 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -24,11 +24,11 @@ dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 vgscan 2>&1 | tee vgscan.out || true
 
-grep "Failed" vgscan.out
+grep "checksum" vgscan.out
 
 dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 vgck $vg 2>&1 | tee vgck.out || true
-grep Incorrect vgck.out
+grep "checksum" vgck.out
 
 vgremove -ff $vg
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 528014c..b0294eb 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -148,6 +148,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	struct logical_volume *lv;
 	int finished = 0;
 	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	int ret;
 
 	if (!parms->wait_before_testing)
@@ -168,12 +169,10 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state);
-		if (vg_read_error(vg)) {
+		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
+		if (!vg) {
 			/* What more could we do here? */
-			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
-			release_vg(vg);
-			vg = NULL;
+			log_error("ABORTING: Can't reread VG for %s error flags %x.", id->display_name, error_flags);
 			ret = 0;
 			goto out;
 		}
@@ -395,6 +394,7 @@ static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *i
 	struct volume_group *vg;
 	struct logical_volume *lv;
 	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	int ret;
 
 	/*
@@ -407,10 +407,9 @@ static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *i
 	 * change done locally.
 	 */
 
-	vg = vg_read(cmd, id->vg_name, NULL, 0, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		log_error("Can't reread VG for %s", id->display_name);
+	vg = vg_read(cmd, id->vg_name, NULL, 0, lockd_state, &error_flags, NULL);
+	if (!vg) {
+		log_error("Can't reread VG for %s error flags %x", id->display_name, error_flags);
 		ret = 0;
 		goto out_ret;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 78b1745..a3b5fea 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -189,11 +189,12 @@ static int _printed_clustered_vg_advice = 0;
  * Case c covers the other errors returned when reading the VG.
  *   If *skip is 1, it's OK for the caller to read the list of PVs in the VG.
  */
-static int _ignore_vg(struct volume_group *vg, const char *vg_name,
-		      struct dm_list *arg_vgnames, uint32_t read_flags,
-		      int *skip, int *notfound)
+static int _ignore_vg(struct cmd_context *cmd,
+		      uint32_t error_flags, struct volume_group *error_vg,
+		      const char *vg_name, struct dm_list *arg_vgnames,
+		      uint32_t read_flags, int *skip, int *notfound)
 {
-	uint32_t read_error = vg_read_error(vg);
+	uint32_t read_error = error_flags;
 
 	*skip = 0;
 	*notfound = 0;
@@ -203,12 +204,9 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		return 0;
 	}
 
-	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_ALLOW_INCONSISTENT))
-		read_error &= ~FAILED_INCONSISTENT; /* Check for other errors */
-
 	if (read_error & FAILED_CLUSTERED) {
-		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Cannot access clustered VG %s.", vg->name);
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg_name)) {
+			log_error("Cannot access clustered VG %s.", vg_name);
 			if (!_printed_clustered_vg_advice) {
 				_printed_clustered_vg_advice = 1;
 				log_error("See lvmlockd(8) for changing a clvm/clustered VG to a shared VG.");
@@ -233,10 +231,13 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 * would expect to fail.
 	 */
 	if (read_error & FAILED_SYSTEMID) {
-		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg_name)) {
 			log_error("Cannot access VG %s with system ID %s with %slocal system ID%s%s.",
-				  vg->name, vg->system_id, vg->cmd->system_id ? "" : "unknown ",
-				  vg->cmd->system_id ? " " : "", vg->cmd->system_id ? vg->cmd->system_id : "");
+				  vg_name,
+				  error_vg ? error_vg->system_id : "unknown ",
+				  cmd->system_id ? "" : "unknown ",
+				  cmd->system_id ? " " : "",
+				  cmd->system_id ? cmd->system_id : "");
 			return 1;
 		} else {
 			read_error &= ~FAILED_SYSTEMID; /* Check for other errors */
@@ -255,10 +256,11 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 * command failed to acquire the necessary lock.)
 	 */
 	if (read_error & (FAILED_LOCK_TYPE | FAILED_LOCK_MODE)) {
-		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg_name)) {
 			if (read_error & FAILED_LOCK_TYPE)
 				log_error("Cannot access VG %s with lock type %s that requires lvmlockd.",
-					  vg->name, vg->lock_type);
+					  vg_name,
+					  error_vg ? error_vg->lock_type : "unknown");
 			/* For FAILED_LOCK_MODE, the error is printed in vg_read. */
 			return 1;
 		} else {
@@ -1924,10 +1926,12 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	log_report_t saved_log_report_state = log_get_report_state();
 	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
+	struct volume_group *error_vg = NULL;
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
 	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -1977,13 +1981,18 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 			continue;
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state, &error_flags, &error_vg);
+		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			report_log_ret_code(ret_max);
+			if (error_vg)
+				unlock_and_release_vg(cmd, error_vg, vg_name);
 			goto endvg;
 		}
+		if (error_vg)
+			unlock_and_release_vg(cmd, error_vg, vg_name);
+
 		if (skip || notfound)
 			goto endvg;
 
@@ -2004,8 +2013,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				ret_max = ret;
 		}
 
-		if (!vg_read_error(vg))
-			unlock_vg(cmd, vg, vg_name);
+		unlock_vg(cmd, vg, vg_name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -3590,11 +3598,13 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 	log_report_t saved_log_report_state = log_get_report_state();
 	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
+	struct volume_group *error_vg = NULL;
 	struct vgnameid_list *vgnl;
 	struct dm_str_list *sl;
 	struct dm_list *tags_arg;
 	struct dm_list lvnames;
 	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	const char *vg_name;
 	const char *vg_uuid;
 	const char *vgn;
@@ -3663,13 +3673,18 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			continue;
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state, &error_flags, &error_vg);
+		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			report_log_ret_code(ret_max);
+			if (error_vg)
+				unlock_and_release_vg(cmd, error_vg, vg_name);
 			goto endvg;
 		}
+		if (error_vg)
+			unlock_and_release_vg(cmd, error_vg, vg_name);
+
 		if (skip || notfound)
 			goto endvg;
 
@@ -4294,10 +4309,12 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	log_report_t saved_log_report_state = log_get_report_state();
 	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
+	struct volume_group *error_vg;
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
 	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
@@ -4335,8 +4352,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 
 		log_debug("Processing PVs in VG %s", vg_name);
 
-		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
+		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state, &error_flags, &error_vg);
+		if (_ignore_vg(cmd, error_flags, error_vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			report_log_ret_code(ret_max);
@@ -4348,22 +4365,26 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			goto endvg;
 		
 		/*
-		 * Don't continue when skip is set, because we need to remove
-		 * vg->pvs entries from devices list.
+		 * Don't call "continue" when skip is set, because we need to remove
+		 * error_vg->pvs entries from devices list.
 		 */
 		
-		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_devices, arg_tags,
+		ret = _process_pvs_in_vg(cmd, vg ? vg : error_vg, all_devices, arg_devices, arg_tags,
 					 process_all_pvs, process_all_devices, skip,
 					 handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
+
 		report_log_ret_code(ret);
+
 		if (ret > ret_max)
 			ret_max = ret;
 
 		if (!skip)
 			unlock_vg(cmd, vg, vg->name);
 endvg:
+		if (error_vg)
+			unlock_and_release_vg(cmd, error_vg, vg_name);
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
@@ -5584,7 +5605,7 @@ do_command:
 	if (pp->preserve_existing && pp->orphan_vg_name) {
 		log_debug("Using existing orphan PVs in %s.", pp->orphan_vg_name);
 
-		if (!(orphan_vg = vg_read_orphans(cmd, 0, pp->orphan_vg_name))) {
+		if (!(orphan_vg = vg_read_orphans(cmd, pp->orphan_vg_name))) {
 			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
 			goto bad;
 		}
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 5a0fb13..49779ca 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -67,12 +67,6 @@ static int _vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
 			return_ECMD_FAILED;
 	} else {
-		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
-			log_error("No backup taken: specify filename with -f "
-				  "to backup an inconsistent VG");
-			return ECMD_FAILED;
-		}
-
 		if (vg_missing_pv_count(vg)) {
 			log_error("No backup taken: specify filename with -f to backup with missing PVs.");
 			return ECMD_FAILED;
@@ -116,7 +110,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_INCONSISTENT, 0,
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0,
 			      handle, &_vg_backup_single);
 
 	free(last_filename);
diff --git a/tools/vgextend.c b/tools/vgextend.c
index e50a818..da76898 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -28,16 +28,25 @@ static int _restore_pv(struct volume_group *vg, const char *pv_name)
 		return 0;
 	}
 
-	if (!(pvl->pv->status & MISSING_PV)) {
-		log_warn("WARNING: PV %s was not missing in VG %s", pv_name, vg->name);
-		return 0;
-	}
-
 	if (!pvl->pv->dev) {
 		log_warn("WARNING: The PV %s is still missing.", pv_name);
 		return 0;
 	}
 
+	if (pvl->pv->status & MISSING_PV)
+		goto clear_flag;
+
+	/*
+	 * when the PV has no used PE's vg_read clears the MISSING_PV flag
+	 * and sets this so we know.
+	 */
+	if (pvl->pv->unused_missing_cleared)
+		goto clear_flag;
+
+	log_warn("WARNING: PV %s was not missing in VG %s", pv_name, vg->name);
+	return 0;
+
+clear_flag:
 	pvl->pv->status &= ~MISSING_PV;
 	return 1;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 8dd81ad..abf7013 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -456,6 +456,7 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 					int *existing_vg)
 {
 	struct volume_group *vg_to = NULL;
+	int exists = 0;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
@@ -468,13 +469,13 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 	 * we obtained a WRITE lock and could not find the vgname in the
 	 * system.  Thus, the split will be into a new VG.
 	 */
-	vg_to = vg_lock_and_create(cmd, vg_name_to);
-	if (vg_read_error(vg_to) == FAILED_LOCKING) {
+	vg_to = vg_lock_and_create(cmd, vg_name_to, &exists);
+	if (!vg_to && !exists) {
 		log_error("Can't get lock for %s", vg_name_to);
 		release_vg(vg_to);
 		return NULL;
 	}
-	if (vg_read_error(vg_to) == FAILED_EXIST) {
+	if (!vg_to && exists) {
 		*existing_vg = 1;
 		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);


