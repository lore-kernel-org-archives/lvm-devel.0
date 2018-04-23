From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:55 -0400
Subject: master - scan: add a dev to bcache before each read to handle write path
Message-ID: <201804231349.w3NDntqG031717@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d2add136192a08be7b3441b6fbe583c27b03dc8
Commit:        9d2add136192a08be7b3441b6fbe583c27b03dc8
Parent:        6c67c7557c266063db962807aca18fc088ba921e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 12:50:44 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: add a dev to bcache before each read to handle write path

This is a temporary hacky workaround to the problem of
reads going through bcache and writes not using bcache.
The write path wants to read parts of data that it is
incrementally writing to disk, but the reads (using
bcache) don't work because the writes are not in the
bcache.  For now, add a dev to bcache before each attempt
to read it in case it's being used on the write path.
---
 lib/format_text/format-text.c |    6 ++++++
 lib/label/label.c             |   18 ++++++++++++++++++
 lib/label/label.h             |    1 +
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a5d8397..f33451f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -320,6 +320,8 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	log_debug_metadata("Reading mda header sector from %s at %llu",
 			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 
+	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
+
 	if (!bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to read metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
@@ -462,6 +464,8 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
+	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
+
 	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
@@ -1209,6 +1213,8 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
+	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
+
 	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
diff --git a/lib/label/label.c b/lib/label/label.c
index 2ec187c..5da781e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -786,3 +786,21 @@ int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_s
 	return label_read(dev, labelp, 0);
 }
 
+/*
+ * FIXME: remove this.  It should not be needed once writes are going through
+ * bcache.  As it is now, the write path involves multiple writes to a device,
+ * and later writes want to read previous writes from disk.  They do these
+ * reads using the standard read paths which require the devs to be in bcache,
+ * but the bcache reads do not find the dev because the writes have gone around
+ * bcache.  To work around this for now, check if each dev is in bcache before
+ * reading it, and if not add it first.
+ */
+
+void label_scan_confirm(struct device *dev)
+{
+	if (!_in_bcache(dev)) {
+		log_warn("add dev %s to bcache", dev_name(dev));
+		label_read(dev, NULL, 0);
+	}
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index eb62f64..e265a6b 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -109,5 +109,6 @@ void label_scan_invalidate(struct device *dev);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
 int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
+void label_scan_confirm(struct device *dev);
 
 #endif


