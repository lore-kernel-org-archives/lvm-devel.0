From: David Teigland <teigland@sourceware.org>
Date: Fri, 23 Apr 2021 22:37:37 +0000 (GMT)
Subject: main - label_read_pvid: separate error and no-pvid
Message-ID: <20210423223737.61F623B33C2A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4dc5d4ac7e7a9457ccc46ff04796b347e58bf4da
Commit:        4dc5d4ac7e7a9457ccc46ff04796b347e58bf4da
Parent:        fcbed26393f57d49daa7da73922b1a922f9523a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 23 17:32:37 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 23 17:37:08 2021 -0500

label_read_pvid: separate error and no-pvid

error reading dev and no pvid on dev were both
returning 0.  make it easier for callers to
know which, if they care.

return 1 if the device could be read, regardless
of whether a pvid was found or not.
set has_pvid=1 if a pvid is found and 0 if no
pvid is found.
---
 lib/device/device_id.c | 11 +++++++++--
 lib/label/label.c      | 14 ++++++++++----
 lib/label/label.h      |  2 +-
 tools/lvmdevices.c     | 14 +++++++++++---
 tools/pvscan.c         | 10 +++++++++-
 5 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 6fa3b0360..67f72e51b 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1912,6 +1912,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	 */
 	dm_list_iterate_items(devl, &search_devs) {
 		dev = devl->dev;
+		int has_pvid;
 
 		/*
 		 * We only need to check devs that would use ID_TYPE_DEVNAME
@@ -1935,11 +1936,17 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 
 		/*
 		 * Reads 4K from the start of the disk.
+		 * Returns 0 if the dev cannot be read.
 		 * Looks for LVM header, and sets dev->pvid if the device is a PV.
-		 * Returns 0 if the dev has no lvm label or no PVID.
+		 * Sets has_pvid=1 if the dev has an lvm PVID.
 		 * This loop may look at and skip many non-LVM devices.
 		 */
-		if (!label_read_pvid(dev)) {
+		if (!label_read_pvid(dev, &has_pvid)) {
+			no_pvid++;
+			continue;
+		}
+
+		if (!has_pvid) {
 			no_pvid++;
 			continue;
 		}
diff --git a/lib/label/label.c b/lib/label/label.c
index 9ebbb4ec9..cfb9ebc80 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1277,7 +1277,7 @@ int label_scan(struct cmd_context *cmd)
  * Read the header of the disk and if it's a PV
  * save the pvid in dev->pvid.
  */
-int label_read_pvid(struct device *dev)
+int label_read_pvid(struct device *dev, int *has_pvid)
 {
 	char buf[4096] __attribute__((aligned(8)));
 	struct label_header *lh;
@@ -1296,14 +1296,17 @@ int label_read_pvid(struct device *dev)
 	 */
 	if (!dev_read_bytes(dev, 0, 4096, buf)) {
 		label_scan_invalidate(dev);
-		return 0;
+		return_0;
 	}
 
+	if (has_pvid)
+		*has_pvid = 0;
+
 	lh = (struct label_header *)(buf + 512);
 	if (memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
 		/* Not an lvm deice */
 		label_scan_invalidate(dev);
-		return 0;
+		return 1;
 	}
 
 	/*
@@ -1313,9 +1316,12 @@ int label_read_pvid(struct device *dev)
 	if (memcmp(lh->type, LVM2_LABEL, sizeof(lh->type))) {
 		/* Not an lvm deice */
 		label_scan_invalidate(dev);
-		return 0;
+		return 1;
 	}
 
+	if (has_pvid)
+		*has_pvid = 1;
+
 	pvh = (struct pv_header *)(buf + 512 + 32);
 	memcpy(dev->pvid, pvh->pv_uuid, ID_LEN);
 	return 1;
diff --git a/lib/label/label.h b/lib/label/label.h
index fae0f1bcc..fcdc309ac 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -117,7 +117,7 @@ int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
 int label_scan_reopen_rw(struct device *dev);
-int label_read_pvid(struct device *dev);
+int label_read_pvid(struct device *dev, int *has_pvid);
 
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index b67db7464..6b3e05683 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -62,8 +62,12 @@ static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *sear
 	 * searching for.
 	 */
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		int has_pvid;
+
 		/* sets dev->pvid if an lvm label with pvid is found */
-		if (!label_read_pvid(devl->dev))
+		if (!label_read_pvid(devl->dev, &has_pvid))
+			continue;
+		if (!has_pvid)
 			continue;
 
 		found = 0;
@@ -181,7 +185,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				continue;
 			dev = du->dev;
 
-			label_read_pvid(dev);
+			if (!label_read_pvid(dev, NULL))
+				continue;
 
 			/*
 			 * label_read_pvid has read the first 4K of the device
@@ -283,7 +288,10 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * (it's ok if the device is not a PV and has no PVID)
 		 */
 		label_scan_setup_bcache();
-		label_read_pvid(dev);
+		if (!label_read_pvid(dev, NULL)) {
+			log_error("Failed to read %s.", devname);
+			goto bad;
+		}
 
 		/*
 		 * Allow filtered devices to be added to devices_file, but
diff --git a/tools/pvscan.c b/tools/pvscan.c
index df38e1758..f8d27372b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1546,7 +1546,15 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	label_scan_setup_bcache();
 
 	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
-		if (!label_read_pvid(devl->dev)) {
+		int has_pvid;
+
+		if (!label_read_pvid(devl->dev, &has_pvid)) {
+			log_print("pvscan[%d] %s cannot read.", getpid(), dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
+		if (!has_pvid) {
 			/* Not an lvm device */
 			log_print("pvscan[%d] %s not an lvm device.", getpid(), dev_name(devl->dev));
 			dm_list_del(&devl->list);


