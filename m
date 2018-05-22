From: David Teigland <teigland@sourceware.org>
Date: Tue, 22 May 2018 15:08:37 -0400
Subject: master - filters: clarify some parts of md filter
Message-ID: <201805221908.w4MJ8bCK016948@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61583281e5703f8b923654d0ff1576d6093d2ead
Commit:        61583281e5703f8b923654d0ff1576d6093d2ead
Parent:        3c9ed33f83c90aa15e57ba6dc12d8f1a80afab6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 22 14:07:13 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 22 14:07:13 2018 -0500

filters: clarify some parts of md filter

Rename some functions to be consistent with the return values,
and add some comments about how it works.
---
 lib/filters/filter-md.c |   89 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 78 insertions(+), 11 deletions(-)

diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index bb8a7cf..ab97b59 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -20,13 +20,77 @@
 
 #define MSG_SKIPPING "%s: Skipping md component device"
 
-static int _ignore_md(struct device *dev, int full)
+/*
+ * The purpose of these functions is to ignore md component devices,
+ * e.g. if /dev/md0 is a raid1 composed of /dev/loop0 and /dev/loop1,
+ * lvm wants to deal with md0 and ignore loop0 and loop1.  md0 should
+ * pass the filter, and loop0,loop1 should not pass the filter so lvm
+ * will ignore them.
+ *
+ * (This is assuming lvm.conf md_component_detection=1.)
+ *
+ * If lvm does *not* ignore the components, then lvm will read lvm
+ * labels from the md dev and from the component devs, and will see
+ * them all as duplicates of each other.  LVM duplicate resolution
+ * will then kick in and keep the md dev around to use and ignore
+ * the components.
+ *
+ * It is better to exclude the components as early as possible during
+ * lvm processing, ideally before lvm even looks for labels on the
+ * components, so that duplicate resolution can be avoided.  There are
+ * a number of ways that md components can be excluded earlier than
+ * the duplicate resolution phase:
+ *
+ * - When external_device_info_source="udev", lvm discovers a device is
+ *   an md component by asking udev during the initial filtering phase.
+ *   However, lvm's default is to not use udev for this.  The
+ *   alternative is "native" detection in which lvm tries to detect
+ *   md components itself.
+ *
+ * - When using native detection, lvm's md filter looks for the md
+ *   superblock at the start of devices.  It will see the md superblock
+ *   on the components, exclude them in the md filter, and avoid
+ *   handling them later in duplicate resolution.
+ *
+ * - When using native detection, lvm's md filter will not detect
+ *   components when the md device has an older superblock version that
+ *   places the superblock at the end of the device.  This case will
+ *   fall back to duplicate resolution to exclude components.
+ *
+ * A variation of the description above occurs for lvm commands that
+ * intend to create new PVs on devices (pvcreate, vgcreate, vgextend).
+ * For these commands, the native md filter also reads the end of all
+ * devices to check for the odd md superblocks.
+ *
+ * (The reason that external_device_info_source is not set to udev by
+ * default is that there have be issues with udev not being promptly
+ * or reliably updated about md state changes, causing the udev info
+ * that lvm uses to be occasionally wrong.)
+ */
+
+/*
+ * Returns 0 if:
+ * the device is an md component and it should be ignored.
+ *
+ * Returns 1 if:
+ * the device is not md component and should not be ignored.
+ *
+ * The actual md device will pass this filter and should be used,
+ * it is the md component devices that we are trying to exclude
+ * that will not pass.
+ */
+
+static int _passes_md_filter(struct device *dev, int full)
 {
 	int ret;
-	
+
+	/*
+	 * When md_component_dectection=0, don't even try to skip md
+	 * components.
+	 */
 	if (!md_filtering())
 		return 1;
-	
+
 	ret = dev_is_md(dev, NULL, full);
 
 	if (ret == -EAGAIN) {
@@ -36,6 +100,9 @@ static int _ignore_md(struct device *dev, int full)
 		return 1;
 	}
 
+	if (ret == 0)
+		return 1;
+
 	if (ret == 1) {
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
@@ -54,16 +121,16 @@ static int _ignore_md(struct device *dev, int full)
 	return 1;
 }
 
-static int _ignore_md_lite(struct dev_filter *f __attribute__((unused)),
-		           struct device *dev)
+static int _passes_md_filter_lite(struct dev_filter *f __attribute__((unused)),
+				  struct device *dev)
 {
-	return _ignore_md(dev, 0);
+	return _passes_md_filter(dev, 0);
 }
 
-static int _ignore_md_full(struct dev_filter *f __attribute__((unused)),
-		           struct device *dev)
+static int _passes_md_filter_full(struct dev_filter *f __attribute__((unused)),
+				  struct device *dev)
 {
-	return _ignore_md(dev, 1);
+	return _passes_md_filter(dev, 1);
 }
 
 static void _destroy(struct dev_filter *f)
@@ -91,9 +158,9 @@ struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *d
 	 */
 
 	if (cmd->use_full_md_check)
-		f->passes_filter = _ignore_md_full;
+		f->passes_filter = _passes_md_filter_full;
 	else
-		f->passes_filter = _ignore_md_lite;
+		f->passes_filter = _passes_md_filter_lite;
 
 	f->destroy = _destroy;
 	f->use_count = 0;


