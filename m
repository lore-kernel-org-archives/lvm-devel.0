From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 13:20:32 -0500
Subject: master - label: Wrap _find_labeller params into a struct.
Message-ID: <201801021820.w02IKWn8014808@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3db51e3f0e90e45e6c3734000fa5a5246a1e6c96
Commit:        3db51e3f0e90e45e6c3734000fa5a5246a1e6c96
Parent:        9b830791eabe24b69e82ab480498c617c4d8fc71
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 16:01:10 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 17:15:32 2018 +0000

label: Wrap _find_labeller params into a struct.

Move the actual buffer reading up to _label_read() so _find_labeller()
just examines the buffer supplied.
---
 lib/label/label.c |   62 +++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 44 insertions(+), 18 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 4defc1d..26d94cf 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -119,42 +119,48 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 		stack;
 }
 
-static void _set_label_read_result(int failed, struct device *dev, uint64_t sector, struct label **result)
+struct find_labeller_params {
+	struct device *dev;
+	uint64_t scan_sector;	/* Sector to be scanned */
+
+	uint64_t label_sector;	/* Sector where label found */
+	struct label **result;
+};
+
+static void _set_label_read_result(int failed, struct find_labeller_params *flp)
 {
+	struct label **result = flp->result;
+
 	if (failed)
 		goto_out;
 
 	if (result && *result) {
-		(*result)->dev = dev;
-		(*result)->sector = sector;
+		(*result)->dev = flp->dev;
+		(*result)->sector = flp->label_sector;
 	}
 
 out:
-	if (!dev_close(dev))
+	if (!dev_close(flp->dev))
 		stack;
 }
 
-static int _find_labeller(struct device *dev, uint64_t scan_sector, struct label **result)
+static int _find_labeller(struct find_labeller_params *flp, char *readbuf)
 {
+	struct device *dev = flp->dev;
+	uint64_t scan_sector = flp->scan_sector;
+	struct label **result = flp->result;
 	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
-	uint64_t label_sector;
 	struct labeller_i *li;
 	struct labeller *l = NULL;	/* Set when a labeller claims the label */
 	struct label_header *lh;
 	struct lvmcache_info *info;
 	uint64_t sector;
-	char *buf = NULL;
 	int r = 0;
 
-	if (!(buf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
-		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		goto out;
-	}
-
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (buf + (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (readbuf + (sector << SECTOR_SHIFT));
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (l) {
@@ -196,15 +202,14 @@ static int _find_labeller(struct device *dev, uint64_t scan_sector, struct label
 					continue;
 				}
 				memcpy(labelbuf, lh, LABEL_SIZE);
-				label_sector = sector + scan_sector;
+				flp->label_sector = sector + scan_sector;
 				l = li->l;
 				break;
 			}
 		}
 	}
 
-      out:
-	dm_free(buf);
+	dm_free(readbuf);
 
 	if (!l) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
@@ -213,7 +218,7 @@ static int _find_labeller(struct device *dev, uint64_t scan_sector, struct label
 	} else
 		r = (l->ops->read)(l, dev, labelbuf, result);
 
-	_set_label_read_result(!r, dev, label_sector, result);
+	_set_label_read_result(!r, flp);
 
 	return r;
 }
@@ -296,6 +301,8 @@ int label_remove(struct device *dev)
 static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result)
 {
 	struct lvmcache_info *info;
+	struct find_labeller_params *flp;
+	char *readbuf = NULL;
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
@@ -303,6 +310,19 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 1;
 	}
 
+	if (!(flp = dm_pool_zalloc(_labeller_mem, sizeof *flp))) {
+		log_error("find_labeller_params allocation failed.");
+		return 0;
+	}
+
+	flp->dev = dev;
+	flp->scan_sector = scan_sector;
+	flp->result = result;
+
+	/* Ensure result is always wiped as a precaution */
+	if (result)
+		*result = NULL;
+
 	log_debug_devs("Reading label from device %s", dev_name(dev));
 
 	if (!dev_open_readonly(dev)) {
@@ -314,7 +334,13 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	return _find_labeller(dev, scan_sector, result);
+	if (!(readbuf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
+		log_debug_devs("%s: Failed to read label area", dev_name(dev));
+		_set_label_read_result(1, flp);
+		return 0;
+	}
+
+	return _find_labeller(flp, readbuf);
 }
 
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)


