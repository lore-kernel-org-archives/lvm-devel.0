From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 13:20:23 -0500
Subject: master - label: Move _set_label_read_result call into _find_labeller.
Message-ID: <201801021820.w02IKNWP014786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b830791eabe24b69e82ab480498c617c4d8fc71
Commit:        9b830791eabe24b69e82ab480498c617c4d8fc71
Parent:        4f4ddb806d9e27f141d76b4b80113948da012426
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 14:58:21 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 15:30:58 2018 +0000

label: Move _set_label_read_result call into _find_labeller.

Move responsibility for setting the label_read() result parameter down
into _find_labeller().
---
 lib/label/label.c |   57 +++++++++++++++++++++++++---------------------------
 1 files changed, 27 insertions(+), 30 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 04db752..4defc1d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -119,25 +119,32 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 		stack;
 }
 
-static void _set_label_read_result(struct device *dev, uint64_t sector, struct label **result)
+static void _set_label_read_result(int failed, struct device *dev, uint64_t sector, struct label **result)
 {
+	if (failed)
+		goto_out;
+
 	if (result && *result) {
 		(*result)->dev = dev;
 		(*result)->sector = sector;
 	}
+
+out:
+	if (!dev_close(dev))
+		stack;
 }
 
-static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
-				       uint64_t *label_sector,
-				       uint64_t scan_sector)
+static int _find_labeller(struct device *dev, uint64_t scan_sector, struct label **result)
 {
+	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
+	uint64_t label_sector;
 	struct labeller_i *li;
-	struct labeller *r = NULL;
+	struct labeller *l = NULL;	/* Set when a labeller claims the label */
 	struct label_header *lh;
 	struct lvmcache_info *info;
 	uint64_t sector;
-	int found = 0;
 	char *buf = NULL;
+	int r = 0;
 
 	if (!(buf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
@@ -150,7 +157,7 @@ static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
 		lh = (struct label_header *) (buf + (sector << SECTOR_SHIFT));
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
-			if (found) {
+			if (l) {
 				log_error("Ignoring additional label on %s at "
 					  "sector %" PRIu64, dev_name(dev),
 					  sector + scan_sector);
@@ -170,7 +177,7 @@ static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
 						 "ignoring", dev_name(dev));
 				continue;
 			}
-			if (found)
+			if (l)
 				continue;
 		}
 
@@ -181,18 +188,16 @@ static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
 					         "sector %" PRIu64, 
 						 dev_name(dev), li->name,
 						 sector + scan_sector);
-				if (found) {
+				if (l) {
 					log_error("Ignoring additional label "
 						  "on %s at sector %" PRIu64,
 						  dev_name(dev),
 						  sector + scan_sector);
 					continue;
 				}
-				r = li->l;
 				memcpy(labelbuf, lh, LABEL_SIZE);
-				if (label_sector)
-					*label_sector = sector + scan_sector;
-				found = 1;
+				label_sector = sector + scan_sector;
+				l = li->l;
 				break;
 			}
 		}
@@ -201,11 +206,14 @@ static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
       out:
 	dm_free(buf);
 
-	if (!found) {
+	if (!l) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
-	}
+	} else
+		r = (l->ops->read)(l, dev, labelbuf, result);
+
+	_set_label_read_result(!r, dev, label_sector, result);
 
 	return r;
 }
@@ -285,13 +293,9 @@ int label_remove(struct device *dev)
 	return r;
 }
 
-static int _label_read(struct device *dev, struct label **result, uint64_t scan_sector)
+static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result)
 {
-	char buf[LABEL_SIZE] __attribute__((aligned(8)));
-	struct labeller *l;
-	uint64_t sector;
 	struct lvmcache_info *info;
-	int r = 0;
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
@@ -307,22 +311,15 @@ static int _label_read(struct device *dev, struct label **result, uint64_t scan_
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 
-		return r;
+		return 0;
 	}
 
-	if ((l = _find_labeller(dev, buf, &sector, scan_sector)))
-		if ((r = (l->ops->read)(l, dev, buf, result)))
-			_set_label_read_result(dev, sector, result);
-
-	if (!dev_close(dev))
-		stack;
-
-	return r;
+	return _find_labeller(dev, scan_sector, result);
 }
 
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
 {
-	return _label_read(dev, result, scan_sector);
+	return _label_read(dev, scan_sector, result);
 }
 
 /* Caller may need to use label_get_handler to create label struct! */


