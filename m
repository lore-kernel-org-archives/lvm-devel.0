From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:00 -0500
Subject: master - scan: add simple scan to find a pvid
Message-ID: <88287.119112712205802029@us-mta-372.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94076245df6e99492a7a0bb2d8c2f2bc2616259d
Commit:        94076245df6e99492a7a0bb2d8c2f2bc2616259d
Parent:        74ad2cd76f68596c0a718f3a9d951a4c72214691
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 30 15:11:57 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

scan: add simple scan to find a pvid

---
 lib/label/label.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/label/label.h |    2 +
 2 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 64b7ca0..680630b 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -24,6 +24,8 @@
 #include "lib/activate/activate.h"
 #include "lib/label/hints.h"
 #include "lib/metadata/metadata.h"
+#include "lib/format_text/format-text.h"
+#include "lib/format_text/layout.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -919,6 +921,74 @@ static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_d
 #endif
 }
 
+int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out)
+{
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
+	struct dm_list devs;
+	struct dev_iter *iter;
+	struct device_list *devl, *devl2;
+	struct device *dev;
+	struct pv_header *pvh;
+	int ret = 0;
+
+	dm_list_init(&devs);
+
+	dev_cache_scan();
+
+	if (!(iter = dev_iter_create(cmd->filter, 0))) {
+		log_error("Scanning failed to get devices.");
+		return 0;
+	}
+
+	log_debug_devs("Filtering devices to scan");
+
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (!(devl = zalloc(sizeof(*devl))))
+			continue;
+		devl->dev = dev;
+		dm_list_add(&devs, &devl->list);
+	};
+	dev_iter_destroy(iter);
+
+	if (!scan_bcache) {
+		if (!_setup_bcache())
+			goto_out;
+	}
+
+	log_debug_devs("Reading labels for pvid");
+
+	dm_list_iterate_items(devl, &devs) {
+		dev = devl->dev;
+
+		memset(buf, 0, sizeof(buf));
+
+		if (!label_scan_open(dev))
+			continue;
+
+		if (!dev_read_bytes(dev, 512, LABEL_SIZE, buf)) {
+			_scan_dev_close(dev);
+			goto out;
+		}
+
+		pvh = (struct pv_header *)(buf + 32);
+
+		if (!memcmp(pvh->pv_uuid, pvid, ID_LEN)) {
+			*dev_out = devl->dev;
+			_scan_dev_close(dev);
+			break;
+		}
+
+		_scan_dev_close(dev);
+	}
+	ret = 1;
+ out:
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		dm_list_del(&devl->list);
+		free(devl);
+	}
+	return ret;
+}
+
 /*
  * Scan devices on the system to discover which are LVM devices.
  * Info about the LVM devices (PVs) is saved in lvmcache in a
diff --git a/lib/label/label.h b/lib/label/label.h
index 33a91fa..4108906 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -118,6 +118,8 @@ int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
 
+int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
+
 /*
  * Wrappers around bcache equivalents.
  * (these make it easier to disable bcache and revert to direct rw if needed)



