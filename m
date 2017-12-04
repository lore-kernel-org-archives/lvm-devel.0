From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 4 Dec 2017 18:23:41 -0500
Subject: master - device: categorise block i/o
Message-ID: <201712042323.vB4NNf8Q012083@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cefef041a46bff9521e6f22556e1b95f726e33e
Commit:        9cefef041a46bff9521e6f22556e1b95f726e33e
Parent:        698483b5a1bc71e3f48581e2e0bbc269e7d237a9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 4 23:18:56 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 4 23:18:56 2017 +0000

device: categorise block i/o

Introduce enum dev_io_reason to categorise block device I/O
in debug messages so it's obvious what it is for.

DEV_IO_SIGNATURES   /* Scanning device signatures */
DEV_IO_LABEL        /* LVM PV disk label */
DEV_IO_MDA_HEADER   /* Text format metadata area header */
DEV_IO_MDA_CONTENT  /* Text format metadata area content */
DEV_IO_FMT1         /* Original LVM1 metadata format */
DEV_IO_POOL         /* Pool metadata format */
DEV_IO_LV           /* Content written to an LV */
DEV_IO_LOG          /* Logging messages */
---
 WHATS_NEW                      |    1 +
 lib/config/config.c            |    2 +-
 lib/device/dev-io.c            |   58 ++++++++++++++++++++++++---------------
 lib/device/dev-luks.c          |    2 +-
 lib/device/dev-md.c            |    2 +-
 lib/device/dev-swap.c          |    2 +-
 lib/device/dev-type.c          |    6 ++--
 lib/device/device.h            |   24 +++++++++++++---
 lib/format1/disk-rep.c         |   22 +++++++-------
 lib/format_pool/disk_rep.c     |    2 +-
 lib/format_text/archiver.c     |    2 +-
 lib/format_text/format-text.c  |   35 +++++++++++-------------
 lib/label/label.c              |    8 +++---
 lib/locking/lvmlockd.c         |    2 +-
 lib/log/log.c                  |    2 +-
 lib/metadata/lv_manip.c        |    2 +-
 lib/metadata/metadata-liblvm.c |    2 +-
 lib/metadata/metadata.c        |    2 +-
 lib/metadata/mirror.c          |    2 +-
 tools/toollib.c                |    2 +-
 20 files changed, 103 insertions(+), 77 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8bbe4ee..541d764 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Categorise I/O with reason annotations in debug messages.
   Command will lock memory only when suspending volumes.
   Merge segments when pvmove is finished.
   Remove label_verify that has never been used.
diff --git a/lib/config/config.c b/lib/config/config.c
index e8e330b..947cb7b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -533,7 +533,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			return 0;
 		}
 		if (!dev_read_circular(dev, (uint64_t) offset, size,
-				       (uint64_t) offset2, size2, buf)) {
+				       (uint64_t) offset2, size2, DEV_IO_MDA_CONTENT, buf)) {
 			goto out;
 		}
 		fb = buf;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 35c510f..e108437 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -56,11 +56,27 @@
 static DM_LIST_INIT(_open_devices);
 static unsigned _dev_size_seqno = 1;
 
+static const char *_reasons[] = {
+	"dev signatures",
+	"PV labels",
+	"VG metadata header",
+	"VG metadata content",
+	"LVM1 metadata",
+	"pool metadata",
+	"LV content",
+	"logging",
+};
+
+static const char *_reason_text(dev_io_reason_t reason)
+{
+	return _reasons[(unsigned) reason];
+}
+
 /*-----------------------------------------------------------------
  * The standard io loop that keeps submitting an io until it's
  * all gone.
  *---------------------------------------------------------------*/
-static int _io(struct device_area *where, char *buffer, int should_write)
+static int _io(struct device_area *where, char *buffer, int should_write, dev_io_reason_t reason)
 {
 	int fd = dev_fd(where->dev);
 	ssize_t n = 0;
@@ -72,10 +88,10 @@ static int _io(struct device_area *where, char *buffer, int should_write)
 		return 0;
 	}
 
-	log_debug_io("%s %s:%8" PRIu64 " bytes (sync) at %" PRIu64 "%s",
+	log_debug_io("%s %s:%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
 		     should_write ? "Write" : "Read ", dev_name(where->dev),
 		     where->size, (uint64_t) where->start,
-		     (should_write && test_mode()) ? " (test mode - suppressed)" : "");
+		     (should_write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(reason));
 
 	/*
 	 * Skip all writes in test mode.
@@ -210,7 +226,7 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 }
 
 static int _aligned_io(struct device_area *where, char *buffer,
-		       int should_write)
+		       int should_write, dev_io_reason_t reason)
 {
 	char *bounce, *bounce_buf;
 	unsigned int physical_block_size = 0;
@@ -232,10 +248,10 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	mask = block_size - 1;
 	if (!memcmp(where, &widened, sizeof(widened)) &&
 	    !((uintptr_t) buffer & mask))
-		return _io(where, buffer, should_write);
+		return _io(where, buffer, should_write, reason);
 
-	log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s",
-		     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev));
+	log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
+		     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
 
 	/* Allocate a bounce buffer with an extra block */
 	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
@@ -250,7 +266,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
 
 	/* channel the io through the bounce buffer */
-	if (!_io(&widened, bounce, 0)) {
+	if (!_io(&widened, bounce, 0, reason)) {
 		if (!should_write)
 			goto_out;
 		/* FIXME pre-extend the file */
@@ -262,7 +278,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		       (size_t) where->size);
 
 		/* ... then we write */
-		if (!(r = _io(&widened, bounce, 1)))
+		if (!(r = _io(&widened, bounce, 1, reason)))
 			stack;
 			
 		goto out;
@@ -699,7 +715,7 @@ static void _dev_inc_error_count(struct device *dev)
 			 dev->max_error_count, dev_name(dev));
 }
 
-int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
+int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
 {
 	struct device_area where;
 	int ret;
@@ -714,9 +730,7 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
 	where.start = offset;
 	where.size = len;
 
-	// fprintf(stderr, "READ: %s, %lld, %d\n", dev_name(dev), offset, len);
-
-	ret = _aligned_io(&where, buffer, 0);
+	ret = _aligned_io(&where, buffer, 0, reason);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
@@ -729,9 +743,9 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
  * 'buf' should be len+len2.
  */
 int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, char *buf)
+		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf)
 {
-	if (!dev_read(dev, offset, len, buf)) {
+	if (!dev_read(dev, offset, len, reason, buf)) {
 		log_error("Read from %s failed", dev_name(dev));
 		return 0;
 	}
@@ -743,7 +757,7 @@ int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 	if (!len2)
 		return 1;
 
-	if (!dev_read(dev, offset2, len2, buf + len)) {
+	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
 		log_error("Circular read from %s failed",
 			  dev_name(dev));
 		return 0;
@@ -757,14 +771,14 @@ int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
  */
 
 /* FIXME pre-extend the file */
-int dev_append(struct device *dev, size_t len, char *buffer)
+int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer)
 {
 	int r;
 
 	if (!dev->open_count)
 		return_0;
 
-	r = dev_write(dev, dev->end, len, buffer);
+	r = dev_write(dev, dev->end, len, reason, buffer);
 	dev->end += (uint64_t) len;
 
 #ifndef O_DIRECT_SUPPORT
@@ -773,7 +787,7 @@ int dev_append(struct device *dev, size_t len, char *buffer)
 	return r;
 }
 
-int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer)
+int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
 {
 	struct device_area where;
 	int ret;
@@ -790,14 +804,14 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer)
 
 	dev->flags |= DEV_ACCESSED_W;
 
-	ret = _aligned_io(&where, buffer, 1);
+	ret = _aligned_io(&where, buffer, 1, reason);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
 	return ret;
 }
 
-int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
+int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value)
 {
 	size_t s;
 	char buffer[4096] __attribute__((aligned(8)));
@@ -816,7 +830,7 @@ int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
 	memset(buffer, value, sizeof(buffer));
 	while (1) {
 		s = len > sizeof(buffer) ? sizeof(buffer) : len;
-		if (!dev_write(dev, offset, s, buffer))
+		if (!dev_write(dev, offset, s, reason, buffer))
 			break;
 
 		len -= s;
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index f7070b2..8513e14 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -31,7 +31,7 @@ int dev_is_luks(struct device *dev, uint64_t *offset_found)
 	if (offset_found)
 		*offset_found = 0;
 
-	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, buf))
+	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
 		goto_out;
 
 	ret = memcmp(buf, LUKS_SIGNATURE, LUKS_SIGNATURE_SIZE) ? 0 : 1;
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 6e0a312..92ee214 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -37,7 +37,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 	uint32_t md_magic;
 
 	/* Version 1 is little endian; version 0.90.0 is machine endian */
-	if (dev_read(dev, sb_offset, sizeof(uint32_t), &md_magic) &&
+	if (dev_read(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
 	    ((md_magic == MD_SB_MAGIC) ||
 	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC)))))
 		return 1;
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 7d16dd1..a7ff10b 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -61,7 +61,7 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 		if (size < (page >> SECTOR_SHIFT))
 			break;
 		if (!dev_read(dev, page - SIGNATURE_SIZE,
-			      SIGNATURE_SIZE, buf)) {
+			      SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
 			ret = -1;
 			break;
 		}
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 05e5bef..9608146 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -363,7 +363,7 @@ static int _has_partition_table(struct device *dev)
 		uint16_t magic;
 	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
-	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
+	if (!dev_read(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
 		return_0;
 
 	/* FIXME Check for other types of partition table too */
@@ -675,7 +675,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	} else
 		log_verbose(_msg_wiping, type, name);
 
-	if (!dev_set(dev, offset_value, len, 0)) {
+	if (!dev_set(dev, offset_value, len, DEV_IO_SIGNATURES, 0)) {
 		log_error("Failed to wipe %s signature on %s.", type, name);
 		return 0;
 	}
@@ -772,7 +772,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 	}
 
 	log_print_unless_silent("Wiping %s on %s.", type, name);
-	if (!dev_set(dev, offset_found, wipe_len, 0)) {
+	if (!dev_set(dev, offset_found, wipe_len, DEV_IO_SIGNATURES, 0)) {
 		log_error("Failed to wipe %s on %s.", type, name);
 		return 0;
 	}
diff --git a/lib/device/device.h b/lib/device/device.h
index fa03f10..550b9bc 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -79,6 +79,20 @@ struct device {
 	char _padding[7];
 };
 
+/*
+ * All I/O is annotated with the reason it is performed.
+ */
+typedef enum dev_io_reason {
+	DEV_IO_SIGNATURES = 0,  /* Scanning device signatures */
+	DEV_IO_LABEL,		/* LVM PV disk label */
+	DEV_IO_MDA_HEADER,      /* Text format metadata area header */
+	DEV_IO_MDA_CONTENT,     /* Text format metadata area content */
+	DEV_IO_FMT1,		/* Original LVM1 metadata format */
+	DEV_IO_POOL,		/* Pool metadata format */
+	DEV_IO_LV,		/* Content written to an LV */
+	DEV_IO_LOG		/* Logging messages */
+} dev_io_reason_t;
+
 struct device_list {
 	struct dm_list list;
 	struct device *dev;
@@ -129,12 +143,12 @@ int dev_test_excl(struct device *dev);
 int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
-int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer);
+int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
 int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, char *buf);
-int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer);
-int dev_append(struct device *dev, size_t len, char *buffer);
-int dev_set(struct device *dev, uint64_t offset, size_t len, int value);
+		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf);
+int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
+int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer);
+int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value);
 void dev_flush(struct device *dev);
 
 struct device *dev_create_file(const char *filename, struct device *dev,
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index c4d1348..41955af 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -205,7 +205,7 @@ int munge_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 {
-	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), pvd)) {
+	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
@@ -216,7 +216,7 @@ static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 {
-	if (!dev_read(dev, pos, sizeof(*disk), disk))
+	if (!dev_read(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
 		return_0;
 
 	_xlate_lvd(disk);
@@ -228,7 +228,7 @@ int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd)
 {
 	uint64_t pos = pvd->vg_on_disk.base;
 
-	if (!dev_read(dev, pos, sizeof(*vgd), vgd))
+	if (!dev_read(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
 		return_0;
 
 	_xlate_vgd(vgd);
@@ -252,7 +252,7 @@ static int _read_uuids(struct disk_list *data)
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
 	while (pos < end && num_read < data->vgd.pv_cur) {
-		if (!dev_read(data->dev, pos, sizeof(buffer), buffer))
+		if (!dev_read(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
 			return_0;
 
 		if (!(ul = dm_pool_alloc(data->mem, sizeof(*ul))))
@@ -311,7 +311,7 @@ static int _read_extents(struct disk_list *data)
 	if (!extents)
 		return_0;
 
-	if (!dev_read(data->dev, pos, len, extents))
+	if (!dev_read(data->dev, pos, len, DEV_IO_FMT1, extents))
 		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
@@ -539,7 +539,7 @@ static int _write_vgd(struct disk_list *data)
 			   data->pvd.vg_name, dev_name(data->dev), pos, sizeof(*vgd));
 
 	_xlate_vgd(vgd);
-	if (!dev_write(data->dev, pos, sizeof(*vgd), vgd))
+	if (!dev_write(data->dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
 		return_0;
 
 	_xlate_vgd(vgd);
@@ -564,7 +564,7 @@ static int _write_uuids(struct disk_list *data)
 				   data->pvd.vg_name, dev_name(data->dev),
 				   pos, NAME_LEN);
 
-		if (!dev_write(data->dev, pos, NAME_LEN, ul->uuid))
+		if (!dev_write(data->dev, pos, NAME_LEN, DEV_IO_FMT1, ul->uuid))
 			return_0;
 
 		pos += NAME_LEN;
@@ -580,7 +580,7 @@ static int _write_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 			   pos, sizeof(*disk));
 
 	_xlate_lvd(disk);
-	if (!dev_write(dev, pos, sizeof(*disk), disk))
+	if (!dev_write(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
 		return_0;
 
 	_xlate_lvd(disk);
@@ -595,7 +595,7 @@ static int _write_lvs(struct disk_list *data)
 
 	pos = data->pvd.lv_on_disk.base;
 
-	if (!dev_set(data->dev, pos, data->pvd.lv_on_disk.size, 0)) {
+	if (!dev_set(data->dev, pos, data->pvd.lv_on_disk.size, DEV_IO_FMT1, 0)) {
 		log_error("Couldn't zero lv area on device '%s'",
 			  dev_name(data->dev));
 		return 0;
@@ -626,7 +626,7 @@ static int _write_extents(struct disk_list *data)
 			   pos, len);
 
 	_xlate_extents(extents, data->pvd.pe_total);
-	if (!dev_write(data->dev, pos, len, extents))
+	if (!dev_write(data->dev, pos, len, DEV_IO_FMT1, extents))
 		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
@@ -661,7 +661,7 @@ static int _write_pvd(struct disk_list *data)
 			   pos, size);
 
 	_xlate_pvd((struct pv_disk *) buf);
-	if (!dev_write(data->dev, pos, size, buf)) {
+	if (!dev_write(data->dev, pos, size, DEV_IO_FMT1, buf)) {
 		dm_free(buf);
 		return_0;
 	}
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 0462eb4..374ff44 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -40,7 +40,7 @@ static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
 	char buf[512] __attribute__((aligned(8)));
 
 	/* FIXME: Need to check the cache here first */
-	if (!dev_read(dev, UINT64_C(0), 512, buf)) {
+	if (!dev_read(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index d381155..3e519ca 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -493,7 +493,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 				return 0;
 			}
 
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
 				log_error("%s not wiped: aborting", pv_name);
 				if (!dev_close(dev))
 					stack;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 797ead0..31d92a5 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -230,8 +230,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
-		if (!dev_read_circular(area->dev, offset, size,
-				       offset2, size2, buf))
+		if (!dev_read_circular(area->dev, offset, size, offset2, size2, DEV_IO_MDA_CONTENT, buf))
 			goto_out;
 
 		/*
@@ -321,7 +320,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
+	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, DEV_IO_MDA_HEADER, mdah)) {
 		if (!dev_close(dev_area->dev))
 			stack;
 		return_0;
@@ -396,7 +395,7 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, mdah))
+	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, DEV_IO_MDA_HEADER, mdah))
 		return_0;
 
 	return 1;
@@ -450,7 +449,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), vgnamebuf))
+		      sizeof(vgnamebuf), DEV_IO_MDA_CONTENT, vgnamebuf))
 		goto_bad;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
@@ -678,7 +677,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-		       (size_t) (mdac->rlocn.size - new_wrap),
+		       (size_t) (mdac->rlocn.size - new_wrap), DEV_IO_MDA_CONTENT,
 		       fidtc->raw_metadata_buf))
 		goto_out;
 
@@ -687,11 +686,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 				  dev_name(mdac->area.dev), mdac->area.start +
 				  MDA_HEADER_SIZE, new_wrap);
 
-		if (!dev_write(mdac->area.dev,
-			       mdac->area.start + MDA_HEADER_SIZE,
-			       (size_t) new_wrap,
-			       fidtc->raw_metadata_buf +
-			       mdac->rlocn.size - new_wrap))
+		if (!dev_write(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
+			       (size_t) new_wrap, DEV_IO_MDA_CONTENT,
+			       fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap))
 			goto_out;
 	}
 
@@ -1207,7 +1204,7 @@ int vgname_from_mda(const struct format_type *fmt,
 
 	/* Do quick check for a vgname */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      NAME_LEN, buf))
+		      NAME_LEN, DEV_IO_MDA_CONTENT, buf))
 		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
@@ -2316,13 +2313,13 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 
 		/* Wipe metadata area with zeroes. */
 		if (!dev_set(pv->dev, mda_start,
-			     (size_t) ((mda_size > wipe_size) ?
-				       wipe_size : mda_size), 0)) {
-				log_error("Failed to wipe new metadata area "
-					  "at the %s of the %s",
-					   mda_index ? "end" : "start",
-					   pv_dev_name(pv));
-				return 0;
+			     (size_t) ((mda_size > wipe_size) ?  wipe_size : mda_size),
+			     DEV_IO_MDA_HEADER, 0)) {
+			log_error("Failed to wipe new metadata area "
+				  "at the %s of the %s",
+				   mda_index ? "end" : "start",
+				   pv_dev_name(pv));
+			return 0;
 		}
 
 		/* Finally, add new metadata area to PV's format instance. */
diff --git a/lib/label/label.c b/lib/label/label.c
index 7a7c500..249927b 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -122,7 +122,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
 
 	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
-		      LABEL_SCAN_SIZE, readbuf)) {
+		      LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -217,7 +217,7 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
-	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, readbuf)) {
+	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -246,7 +246,7 @@ int label_remove(struct device *dev)
 		if (wipe) {
 			log_very_verbose("%s: Wiping label@sector %" PRIu64,
 					 dev_name(dev), sector);
-			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE,
+			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL,
 				       buf)) {
 				/* Also remove the PV record from cache. */
 				info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
@@ -342,7 +342,7 @@ int label_write(struct device *dev, struct label *label)
 	log_very_verbose("%s: Writing label to sector %" PRIu64 " with stored offset %"
 			 PRIu32 ".", dev_name(dev), label->sector,
 			 xlate32(lh->offset_xl));
-	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
+	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
 		r = 0;
 	}
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index cf2c3d5..325549a 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -412,7 +412,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	if (!dev_set(dev, old_size_bytes, new_size_bytes - old_size_bytes, 0)) {
+	if (!dev_set(dev, old_size_bytes, new_size_bytes - old_size_bytes, DEV_IO_LV, 0)) {
 		log_error("Extend sanlock LV %s cannot zero device.", display_lvname(lv));
 		dev_close_immediate(dev);
 		return 0;
diff --git a/lib/log/log.c b/lib/log/log.c
index 208959b..808090f 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -694,7 +694,7 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 		buf[bufused] = '\n';
 		buf[sizeof(buf) - 1] = '\n';
 		/* FIXME real size bufused */
-		dev_append(&_log_dev, sizeof(buf), buf);
+		dev_append(&_log_dev, sizeof(buf), DEV_IO_LOG, buf);
 		_already_logging = 0;
 	}
 }
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6b2d1f1..70dc2d9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7192,7 +7192,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_size(lv->vg->cmd, zero_sectors),
 			    lv->vg->name, lv->name, wp.zero_value);
 
-		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value))
+		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, DEV_IO_LV, wp.zero_value))
 			stack;
 	}
 
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index 4202950..0ea84e1 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -71,7 +71,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 				return 0;
 			}
 
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LV, 0)) {
 				log_error("%s not wiped: aborting", pv_name);
 				if (!dev_close(dev))
 					stack;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a14dfa6..d17db92 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1456,7 +1456,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 				return 0;
 			}
 
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LV, 0)) {
 				log_error("%s not wiped: aborting", pv_name);
 				if (!dev_close(dev))
 					stack;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 327ce99..38c3df6 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -304,7 +304,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!dev_open_quiet(dev))
 		return 0;
 
-	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), &log_header)) {
+	if (!dev_write(dev, UINT64_C(0), sizeof(log_header), DEV_IO_LV, &log_header)) {
 		log_error("Failed to write log header to %s.", name);
 		dev_close_immediate(dev);
 		return 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index f60014c..0509b5e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5771,7 +5771,7 @@ do_command:
 				continue;
 			}
 
-			if (!dev_set(pv->dev, UINT64_C(0), (size_t) 2048, 0)) {
+			if (!dev_set(pv->dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
 				log_error("%s not wiped: aborting.", pv_name);
 				if (!dev_close(pv->dev))
 					stack;


