From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:16 +0000 (GMT)
Subject: master - add label_read_pvid
Message-ID: <20201022204316.B4623385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=677f829e540ef0f2fa2781f4facc7571dee1fb83
Commit:        677f829e540ef0f2fa2781f4facc7571dee1fb83
Parent:        c7311d472203614b229cf17606d14fb53df85945
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 14:05:45 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

add label_read_pvid

To read the lvm headers and set dev->pvid if the
device is a PV.  Difference from label_scan_ functions
is this does not read any vg metadata or add any info
to lvmcache.
---
 lib/label/label.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/label/label.h |  1 +
 2 files changed, 49 insertions(+)

diff --git a/lib/label/label.c b/lib/label/label.c
index a47cd1731..bc8e60fc9 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1254,6 +1254,54 @@ int label_scan(struct cmd_context *cmd)
 	return 1;
 }
 
+/*
+ * Read the header of the disk and if it's a PV
+ * save the pvid in dev->pvid.
+ */
+int label_read_pvid(struct device *dev)
+{
+	char buf[4096] __attribute__((aligned(8)));
+	struct label_header *lh;
+	struct pv_header *pvh;
+
+	memset(buf, 0, sizeof(buf));
+
+	if (!label_scan_open(dev))
+		return_0;
+
+	/*
+	 * We could do:
+	 * dev_read_bytes(dev, 512, LABEL_SIZE, buf);
+	 * which works, but there's a bcache issue that
+	 * prevents proper invalidation after that.
+	 */
+	if (!dev_read_bytes(dev, 0, 4096, buf)) {
+		label_scan_invalidate(dev);
+		return 0;
+	}
+
+	lh = (struct label_header *)(buf + 512);
+	if (memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
+		/* Not an lvm deice */
+		label_scan_invalidate(dev);
+		return 0;
+	}
+
+	/*
+	 * wipefs -a just clears the type field, leaving the
+	 * rest of the label_header intact.
+	 */
+	if (memcmp(lh->type, LVM2_LABEL, sizeof(lh->type))) {
+		/* Not an lvm deice */
+		label_scan_invalidate(dev);
+		return 0;
+	}
+
+	pvh = (struct pv_header *)(buf + 512 + 32);
+	memcpy(dev->pvid, pvh->pv_uuid, ID_LEN);
+	return 1;
+}
+
 /*
  * Scan and cache lvm data from the listed devices.  If a device is already
  * scanned and cached, this replaces the previously cached lvm data for the
diff --git a/lib/label/label.h b/lib/label/label.h
index 8778c17a8..ddfb34af5 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -117,6 +117,7 @@ int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
 int label_scan_reopen_rw(struct device *dev);
+int label_read_pvid(struct device *dev);
 
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
 


