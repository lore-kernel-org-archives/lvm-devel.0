From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 13:21:21 -0400
Subject: master - devs: rename dev_is_md dev_is_md_component
Message-ID: <201905211721.x4LHLLqG013668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19ef399ea781c2c74d0bc8de92f673648d190016
Commit:        19ef399ea781c2c74d0bc8de92f673648d190016
Parent:        0c26aa13ca588fc552a2748aee5654866ce7cced
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 11:44:39 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 11:44:39 2019 -0500

devs: rename dev_is_md dev_is_md_component

The naming was confusing and misleading since
it it's testing if a device is an md component,
not an md device.
---
 lib/device/dev-md.c           |   27 ++++++++++++++++++++-------
 lib/device/dev-type.c         |    2 +-
 lib/device/dev-type.h         |    2 +-
 lib/filters/filter-md.c       |    2 +-
 lib/format_text/import_vsn1.c |    2 +-
 5 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 15e1280..ab93206 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -88,8 +88,21 @@ static uint64_t _v1_sb_offset(uint64_t size, md_minor_version_t minor_version)
 	return sb_offset;
 }
 
+/*
+ * _udev_dev_is_md_component() only works if
+ *   external_device_info_source="udev"
+ *
+ * but
+ *
+ * udev_dev_is_md_component() in dev-type.c only works if
+ *   obtain_device_list_from_udev=1
+ *
+ * and neither of those config setting matches very well
+ * with what we're doing here.
+ */
+
 #ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_md(struct device *dev)
+static int _udev_dev_is_md_component(struct device *dev)
 {
 	const char *value;
 	struct dev_ext *ext;
@@ -103,7 +116,7 @@ static int _udev_dev_is_md(struct device *dev)
 	return !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID);
 }
 #else
-static int _udev_dev_is_md(struct device *dev)
+static int _udev_dev_is_md_component(struct device *dev)
 {
 	return 0;
 }
@@ -112,7 +125,7 @@ static int _udev_dev_is_md(struct device *dev)
 /*
  * Returns -1 on error
  */
-static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int full)
+static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
 {
 	md_minor_version_t minor;
 	uint64_t size, sb_offset;
@@ -188,7 +201,7 @@ out:
 	return ret;
 }
 
-int dev_is_md(struct device *dev, uint64_t *offset_found, int full)
+int dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
 {
 	int ret;
 
@@ -198,7 +211,7 @@ int dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 	 * information is not in udev db.
 	 */
 	if ((dev->ext.src == DEV_EXT_NONE) || offset_found) {
-		ret = _native_dev_is_md(dev, offset_found, full);
+		ret = _native_dev_is_md_component(dev, offset_found, full);
 
 		if (!full) {
 			if (!ret || (ret == -EAGAIN)) {
@@ -210,7 +223,7 @@ int dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 	}
 
 	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_md(dev);
+		return _udev_dev_is_md_component(dev);
 
 	log_error(INTERNAL_ERROR "Missing hook for MD device recognition "
 		  "using external device info source %s", dev_ext_name(dev));
@@ -439,7 +452,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev)
 
 #else
 
-int dev_is_md(struct device *dev __attribute__((unused)),
+int dev_is_md_component(struct device *dev __attribute__((unused)),
 	      uint64_t *sb __attribute__((unused)))
 {
 	return 0;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e9106a9..f0faa3d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -866,7 +866,7 @@ static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 		wiped = &wiped_tmp;
 	*wiped = 0;
 
-	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, wiped, dev_is_md) ||
+	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, wiped, dev_is_md_component) ||
 	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, wiped, dev_is_swap) ||
 	    !_wipe_signature(dev, "LUKS signature", name, 8, yes, force, wiped, dev_is_luks))
 		return 0;
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index d349905..e090050 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -57,7 +57,7 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev);
 int major_is_scsi_device(struct dev_types *dt, int major);
 
 /* Signature/superblock recognition with position returned where found. */
-int dev_is_md(struct device *dev, uint64_t *sb, int full);
+int dev_is_md_component(struct device *dev, uint64_t *sb, int full);
 int dev_is_swap(struct device *dev, uint64_t *signature, int full);
 int dev_is_luks(struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index d6dd28c..28903be 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -93,7 +93,7 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 	if (!md_filtering())
 		return 1;
 
-	ret = dev_is_md(dev, NULL, cmd->use_full_md_check);
+	ret = dev_is_md_component(dev, NULL, cmd->use_full_md_check);
 
 	if (ret == -EAGAIN) {
 		/* let pass, call again after scan */
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 79c73ae..8dad8e9 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -298,7 +298,7 @@ static int _read_pv(struct format_instance *fid,
 	 * see the PV size, and can finally compare it with the device size.
 	 */
 	if (pv->dev && (pv->size != pv->dev->size)) {
-		if (dev_is_md(pv->dev, NULL, 1)) {
+		if (dev_is_md_component(pv->dev, NULL, 1)) {
 			log_warn("WARNING: device %s is an md component, ignoring PV.", dev_name(pv->dev));
 			return_0;
 		}


