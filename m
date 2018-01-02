From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 13:20:19 -0500
Subject: master - label: Move setting result of label_read into separate fn.
Message-ID: <201801021820.w02IKJpA014770@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f4ddb806d9e27f141d76b4b80113948da012426
Commit:        4f4ddb806d9e27f141d76b4b80113948da012426
Parent:        e6b4b41881b6070b24353496dd32cccc270fe9ce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 14:19:20 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 14:19:20 2018 +0000

label: Move setting result of label_read into separate fn.

---
 lib/label/label.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index fa44f2c..04db752 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -119,6 +119,14 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 		stack;
 }
 
+static void _set_label_read_result(struct device *dev, uint64_t sector, struct label **result)
+{
+	if (result && *result) {
+		(*result)->dev = dev;
+		(*result)->sector = sector;
+	}
+}
+
 static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
 				       uint64_t *label_sector,
 				       uint64_t scan_sector)
@@ -277,8 +285,7 @@ int label_remove(struct device *dev)
 	return r;
 }
 
-int label_read(struct device *dev, struct label **result,
-		uint64_t scan_sector)
+static int _label_read(struct device *dev, struct label **result, uint64_t scan_sector)
 {
 	char buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct labeller *l;
@@ -304,10 +311,8 @@ int label_read(struct device *dev, struct label **result,
 	}
 
 	if ((l = _find_labeller(dev, buf, &sector, scan_sector)))
-		if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
-			(*result)->dev = dev;
-			(*result)->sector = sector;
-		}
+		if ((r = (l->ops->read)(l, dev, buf, result)))
+			_set_label_read_result(dev, sector, result);
 
 	if (!dev_close(dev))
 		stack;
@@ -315,6 +320,11 @@ int label_read(struct device *dev, struct label **result,
 	return r;
 }
 
+int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
+{
+	return _label_read(dev, result, scan_sector);
+}
+
 /* Caller may need to use label_get_handler to create label struct! */
 int label_write(struct device *dev, struct label *label)
 {


