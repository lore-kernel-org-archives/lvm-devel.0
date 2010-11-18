From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:17 +0100
Subject: [PATCH 03/11] Add pv_add_metadata_area to format_handler interface.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-4-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This provides a way to add new metadata area for a PV on demand.
Adding any new metadata area will update the cache directly (just as it
is in the situation while scanning and reading existing PVs). Why cache?
Because when I add a new metadata area, I need to know about other
metadata areas (together with any newly add metadata areas!) So I had
two choices - either I copy the list of existing metadata areas to my
own list and proceed with this one (adding/removing other mdas as
needed) or I can use the cache directly (which we update anyway).
Now, we update it a little bit earlier than we did before.

So there's a question probably - what is our cache policy?

 - read info from disk, cache it, use it and if anything changes,
   throw the cache away immediately and read new info from the disk
   again,

 - read info from disk, cache it, use it, modify it together with any
   modifications we're just doing, use the new cache later on, don't
   read from the disk again (unless really necessary),

 - read info form disk, cache it, use it, modify it only at certain
   points where it is allowed.

The thing is that I really want to avoid making *another* copy of the
mda_list. We already have one in the format_instance, one in the cache,
of course... Another one just for mda add/remove interface? No. So if
this cache modification is no-go, I'd lean to changing the
format_instance itself so it could be used for this mda add/remove
interface as well (but that would require much more changes, I think).

But here's the solution with the cache... It's doing its job so it's
just about the question what's our policy when working with the cache.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/format-text.c |  249 +++++++++++++++++++++++++++++++++++++++++
 lib/format_text/format-text.h |    7 +
 lib/metadata/metadata.h       |   10 ++
 3 files changed, 266 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index af95cb5..0c1c4c7 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1909,6 +1909,254 @@ static int _text_pv_setup(const struct format_type *fmt,
 	return 1;
 }
 
+int add_metadata_area_to_cache(struct lvmcache_info *info,
+			       unsigned mda_index,
+			       uint64_t mda_start,
+			       uint64_t mda_size,
+			       unsigned mda_ignored)
+{
+	struct metadata_area *mda;
+	struct mda_context *mdac;
+	struct mda_lists *mda_lists = (struct mda_lists *) info->fmt->private;
+
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "can't add metadata with index %u to"
+					 "cache for PV %s. Metadata layout "
+					 "not supported by %s format.",
+					  mda_index, dev_name(info->dev),
+					  info->fmt->name);
+	}
+
+	if (!(mda = dm_malloc(sizeof(struct metadata_area)))) {
+		log_error("struct metadata_area allocation failed");
+		return 0;
+	}
+
+	if (!(mdac = dm_malloc(sizeof(struct mda_context)))) {
+		log_error("struct mda_context allocation failed");
+		dm_free(mda);
+		return 0;
+	}
+
+	mda->ops = mda_lists->raw_ops;
+	mda->metadata_locn = mdac;
+	mda->status = 0;
+
+	mdac->area.dev = info->dev;
+	mdac->area.start = mda_start;
+	mdac->area.size = mda_size;
+	mdac->free_sectors = UINT64_C(0);
+	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
+	mda_set_ignored(mda, mda_ignored);
+
+	dm_list_add(&info->mdas, &mda->list);
+	info->mda_slots[mda_index] = mda;
+
+	return 1;
+}
+
+static int _text_pv_add_metadata_area(const struct format_type *fmt,
+				      struct physical_volume *pv,
+				      unsigned mda_index,
+				      uint64_t mda_size,
+				      unsigned mda_ignored)
+{
+	uint64_t pe_start, pe_end;
+	uint64_t alignment, alignment_offset;
+	uint64_t disk_size;
+	uint64_t mda_start;
+	uint64_t adjustment, limit;
+	uint64_t wipe_size = 8 << SECTOR_SHIFT;
+	size_t page_size = lvm_getpagesize();
+	struct lvmcache_info *info;
+	struct metadata_area *mda;
+	struct mda_context *mdac;
+
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "invalid index of value %u used "
+			      "while trying to add metadata area on PV %s. "
+			      "Metadata layout not supported by %s format.",
+			       mda_index, pv_dev_name(pv), fmt->name);
+		return 0;
+	}
+
+	pe_start = pv->pe_start << SECTOR_SHIFT;
+	alignment = pv->pe_align << SECTOR_SHIFT;
+	alignment_offset = pv->pe_align_offset << SECTOR_SHIFT;
+	disk_size = pv->size << SECTOR_SHIFT;
+	mda_size = mda_size << SECTOR_SHIFT;
+
+	if (!(info = info_from_pvid(pv->dev->pvid, 0)))
+		return_0;
+
+	if (info->mda_slots[mda_index]) {
+		log_error(INTERNAL_ERROR "metadata area with index %u already "
+			"exists on PV %s.", mda_index, pv_dev_name(pv));
+		return 0;
+	}
+
+	/* First metadata area at the start of the device. */
+	if (mda_index == 0) {
+		/*
+		 * Try to fit MDA0 end within given pe_start limit if its value
+		 * is locked. If it's not locked, count with any existing MDA1.
+		 * If there's no MDA1, just use disk size as the limit.
+		 */
+		if (pv->pe_start_locked)
+			limit = pe_start;
+		else if ((mda = (struct metadata_area *) info->mda_slots[1]) &&
+			 (mdac = mda->metadata_locn))
+			limit = mdac->area.start;
+		else
+			limit = disk_size;
+
+		if (limit > disk_size)
+			goto bad;
+
+		mda_start = LABEL_SCAN_SIZE;
+
+		/* Align MDA0 start with page size if possible. */
+		if (limit - mda_start >= MDA_SIZE_MIN) {
+			if ((adjustment = mda_start % page_size))
+				mda_start += (page_size - adjustment);
+		}
+
+		/* Align MDA0 end position with given alignment if possible. */
+		if (alignment) {
+			if ((adjustment = (mda_start + mda_size) % alignment)) {
+				mda_size += (alignment - adjustment);
+				if (mda_start + mda_size > limit)
+					mda_size -= (alignment - adjustment);
+			}
+		}
+
+		/* Align MDA0 end position with given alignment offset if possible. */
+		if (alignment_offset &&
+		    (((mda_start + mda_size) % alignment) == 0)) {
+			mda_size += alignment_offset;
+			if (mda_start + mda_size > limit)
+				mda_size -= alignment_offset;
+		}
+
+		if (mda_start + mda_size > limit) {
+			log_warn("WARNING: metadata area size outreaches "
+				 "a limit on PV %s specified by its %s. "
+				 "Trying to adjust metadata area size.",
+				  pv_dev_name(pv),
+				  pv->pe_start_locked ? "PE start"
+						      : "disk size");
+
+			/*
+			 * Try to decrease the MDA0 size with twice the
+			 * alignment and then align with given alignment.
+			 * If pe_start is locked, skip this type of
+			 * alignment since it would be useless.
+			 * Check first whether we can apply that!
+			 */
+			if (!pv->pe_start_locked &&
+			    ((limit - mda_start) > alignment * 2)) {
+				mda_size = limit - mda_start - alignment * 2;
+
+				if ((adjustment = (mda_start + mda_size) % alignment))
+					mda_size += (alignment - adjustment);
+
+				/* Still too much? Then there's nothing else to do. */
+				if (mda_start + mda_size > limit)
+					goto bad;
+			}
+			/* Otherwise, give up and take any usable space. */
+			/* FIXME: We should probably check for some minimum MDA size here. */
+			else
+				mda_size = limit - mda_start;
+		}
+
+		/*
+		 * If PV's pe_start is not locked, update pe_start value with the
+		 * start of the area that follows the MDA0 we've just calculated.
+		 */
+		if (!pv->pe_start_locked) {
+			pe_start = mda_start + mda_size;
+			pv->pe_start = pe_start >> SECTOR_SHIFT;
+		}
+	}
+	/* Second metadata area at the end of the device. */
+	else {
+		/*
+		 * Try to fit MDA1 start within given pe_end or pe_start limit
+		 * if it's locked. If pe_start and pe_end are not defined yet,
+		 * count with any existing MDA0 and pe_start. If MDA0 does not
+		 * exist, just use LABEL_SCAN_SIZE.
+		 */
+		pe_end = pv->pe_count ? (pv->pe_start +
+					 pv->pe_count * pv->pe_size - 1) << SECTOR_SHIFT
+				      : 0;
+		if (pv->pe_start_locked)
+			limit = pe_end ? pe_end : pe_start;
+		else if (pe_start)
+			limit = pe_start;
+		/*
+		 * Normally MDA0's start + size should be pe_start.
+		 * The statemet here is probably useless since the
+		 * situation is covered by previous statement.
+		 */
+		else if ((mda = (struct metadata_area *) info->mda_slots[0]) &&
+			 (mdac = mda->metadata_locn))
+			limit = mdac->area.start + mdac->area.size;
+		else
+			limit = LABEL_SCAN_SIZE;
+
+		if (limit > disk_size || mda_size > disk_size)
+			goto bad;
+
+		mda_start = disk_size - mda_size;
+
+		if (alignment) {
+			adjustment = mda_start % alignment;
+			if (adjustment)
+				mda_size += adjustment;
+		}
+
+		/* FIXME: mda_size should be sanity-checked somewhere before.
+		 *	  I'm not sure whether it really is --> !(mda_size > disk_size). */
+		if (disk_size - mda_size < limit)
+			mda_size = disk_size - limit;
+
+		/*
+		 * If PV's pe_end not set yet, set it to the end of the
+		 * area that precedes the MDA1 we've just calculated.
+		 * FIXME: do we need to set this? Isn't it always set before?
+		 */
+		/*if (!pe_end) {
+			pe_end = mda_start;
+			pv->pe_end = pe_end >> SECTOR_SHIFT;
+		}*/
+	}
+
+	if (mda_size) {
+		/* Wipe metadata area with zeroes. */
+		if (!dev_set((struct device *) pv->dev, mda_start,
+			(size_t) (mda_size > wipe_size ? : mda_size), 0)) {
+				log_error("Failed to wipe new metadata area "
+					  "at the %s of the %s",
+					   mda_index ? "end" : "start",
+					   pv_dev_name(pv));
+				return 0;
+		}
+
+		/* Finally, add new metadata area to cache. */
+		if (!add_metadata_area_to_cache(info, mda_index,
+				mda_start, mda_size, mda_ignored))
+			return_0;
+	}
+
+	return 1;
+
+bad:
+	log_error("Not enough space available for metadata area "
+		  "with index %u on PV %s.", mda_index, pv_dev_name(pv));
+	return 0;
+}
+
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type
 						     *fmt, const char *vgname,
@@ -2049,6 +2297,7 @@ static struct format_handler _text_handler = {
 	.scan = _text_scan,
 	.pv_read = _text_pv_read,
 	.pv_setup = _text_pv_setup,
+	.pv_add_metadata_area = _text_pv_add_metadata_area,
 	.pv_write = _text_pv_write,
 	.vg_setup = _text_vg_setup,
 	.lv_setup = _text_lv_setup,
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 79365ea..75d69bf 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -22,6 +22,7 @@
 #define FMT_TEXT_NAME "lvm2"
 #define FMT_TEXT_ALIAS "text"
 #define FMT_TEXT_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_TEXT_NAME)
+#define FMT_TEXT_MAX_MDAS_PER_PV 2
 
 /*
  * Archives a vg config.  'retain_days' is the minimum number of
@@ -55,6 +56,12 @@ int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size);
 void del_das(struct dm_list *das);
 
+int add_metadata_area_to_cache(struct lvmcache_info *info,
+			       unsigned mda_index,
+			       uint64_t mda_start,
+			       uint64_t mda_size,
+			       unsigned mda_ignored);
+
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 5aa9c19..ca2ec0b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -23,6 +23,7 @@
 
 #include "ctype.h"
 #include "dev-cache.h"
+#include "lvmcache.h"
 #include "lvm-string.h"
 #include "metadata-exported.h"
 
@@ -249,6 +250,15 @@ struct format_handler {
 			 struct physical_volume * pv, struct volume_group * vg);
 
 	/*
+	 * Add metadata area to a PV. Changes will take effect on pv_write.
+	 */
+	int (*pv_add_metadata_area) (const struct format_type * fmt,
+				     struct physical_volume * pv,
+				     unsigned metadata_index,
+				     uint64_t metadata_size,
+				     unsigned metadata_ignored);
+
+	/*
 	 * Write a PV structure to disk. Fails if the PV is in a VG ie
 	 * pv->vg_name must be a valid orphan VG name
 	 */
-- 
1.7.3.2


