From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 Sep 2020 20:10:33 +0000 (GMT)
Subject: master - metadata: open rw fd before closing ro fd
Message-ID: <20200918201033.0CCB43973041@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1404e5ee61bdaddeb07a5e9ecfe1aad477cc9bf9
Commit:        1404e5ee61bdaddeb07a5e9ecfe1aad477cc9bf9
Parent:        1570e76233398957911c3559b40de6e03c37df9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 18 14:42:23 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 18 15:10:11 2020 -0500

metadata: open rw fd before closing ro fd

lvm opens devices readonly to scan them, but
needs to open then readwrite to update the metadata.
Previously, the ro fd was closed before the rw fd
was opened, leaving a small gap where the dev was
not held open, and during which the dev could
possibly change which storage it referred to.

With the bcache_change_fd() interface, lvm opens a
rw fd on a device to be written, tells bcache to
change to the new rw fd, and closes the ro fd.

. open dev ro
. read dev with the ro fd (label_scan)
. lock vg (ex for writing)
. open dev rw
. close ro fd
. rescan dev to check if the metadata changed
  between the scan and the lock
. if the metadata did change, reread in full
. write the metadata
---
 lib/cache/lvmcache.c    | 16 +++++++++++++
 lib/cache/lvmcache.h    |  1 +
 lib/label/label.c       | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/label/label.h       |  1 +
 lib/metadata/metadata.c |  9 +++++++
 5 files changed, 90 insertions(+)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index cad8247c7..d8df4c796 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -996,6 +996,22 @@ int lvmcache_label_rescan_vg_rw(struct cmd_context *cmd, const char *vgname, con
 	return _label_rescan_vg(cmd, vgname, vgid, 1);
 }
 
+int lvmcache_label_reopen_vg_rw(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
+		return_0;
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!label_scan_reopen_rw(info->dev))
+			return_0;
+	}
+
+	return 1;
+}
+
 /*
  * Uses label_scan to populate lvmcache with 'vginfo' struct for each VG
  * and associated 'info' structs for those VGs.  Only VG summary information
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 6cef4d102..1ee99b534 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -69,6 +69,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 int lvmcache_label_scan(struct cmd_context *cmd);
 int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid);
 int lvmcache_label_rescan_vg_rw(struct cmd_context *cmd, const char *vgname, const char *vgid);
+int lvmcache_label_reopen_vg_rw(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *labeller, const char *pvid,
diff --git a/lib/label/label.c b/lib/label/label.c
index afe342629..0090fd0a5 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1447,6 +1447,69 @@ int label_scan_open_rw(struct device *dev)
 	return label_scan_open(dev);
 }
 
+int label_scan_reopen_rw(struct device *dev)
+{
+	int flags = 0;
+	int prev_fd = dev->bcache_fd;
+	int fd;
+
+	if (!(dev->flags & DEV_IN_BCACHE)) {
+		if ((dev->bcache_fd != -1) || (dev->bcache_di != -1)) {
+			/* shouldn't happen */
+			log_debug("Reopen writeable %s uncached fd %d di %d",
+				  dev_name(dev), dev->bcache_fd, dev->bcache_di);
+			return 0;
+		}
+		goto do_open;
+	}
+
+	if ((dev->flags & DEV_BCACHE_WRITE))
+		return 1;
+
+	if (dev->bcache_fd == -1) {
+		log_error("Failed to open writable %s index %d fd none",
+			  dev_name(dev), dev->bcache_di);
+		return 0;
+	}
+	if (dev->bcache_di == -1) {
+		log_error("Failed to open writeable %s index none fd %d",
+			  dev_name(dev), dev->bcache_fd);
+		return 0;
+	}
+
+ do_open:
+	flags |= O_DIRECT;
+	flags |= O_NOATIME;
+	flags |= O_RDWR;
+
+	fd = open(dev_name(dev), flags, 0777);
+	if (fd < 0) {
+		log_error("Failed to open rw %s errno %d di %d fd %d.",
+			  dev_name(dev), errno, dev->bcache_di, dev->bcache_fd);
+		return 0;
+	}
+
+	if (!bcache_change_fd(dev->bcache_di, fd)) {
+		log_error("Failed to change to rw fd %s di %d fd %d.",
+			  dev_name(dev), dev->bcache_di, fd);
+		close(fd);
+		return 0;
+	}
+
+	if (close(dev->bcache_fd))
+		log_debug("reopen writeable %s close prev errno %d di %d fd %d.",
+			  dev_name(dev), errno, dev->bcache_di, dev->bcache_fd);
+
+	dev->flags |= DEV_IN_BCACHE;
+	dev->flags |= DEV_BCACHE_WRITE;
+	dev->bcache_fd = fd;
+
+	log_debug("reopen writable %s di %d prev %d fd %d",
+		  dev_name(dev), dev->bcache_di, prev_fd, fd);
+
+	return 1;
+}
+
 bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	if (!scan_bcache) {
diff --git a/lib/label/label.h b/lib/label/label.h
index 9a4b630bb..25913bb6d 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -117,6 +117,7 @@ int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
+int label_scan_reopen_rw(struct device *dev);
 
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d4a069cd0..5639377e5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4688,6 +4688,15 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	log_debug_metadata("Reading VG %s %s", vgname ?: "<no name>", vgid ?: "<no vgid>");
 
+	/*
+	 * Devices are generally open readonly from scanning, and we need to
+	 * reopen them rw to update metadata.  We want to reopen them rw before
+	 * before rescanning and/or writing.  Reopening rw preserves the existing
+	 * bcache blocks for the devs.
+	 */
+	if (writing)
+		lvmcache_label_reopen_vg_rw(cmd, vgname, vgid);
+
 	/*
 	 * Rescan the devices that are associated with this vg in lvmcache.
 	 * This repeats what was done by the command's initial label scan,


