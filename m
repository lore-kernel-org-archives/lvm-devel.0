From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 May 2011 09:48:20 -0000
Subject: LVM2 lib/device/dev-io.c lib/device/dev-luks.c ...
Message-ID: <20110528094820.24289.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-05-28 09:48:16

Modified files:
	lib/device     : dev-io.c dev-luks.c dev-md.c dev-swap.c 
	lib/format1    : disk-rep.c 
	lib/format_pool: disk_rep.c 
	lib/format_text: format-text.c text_label.c 
	lib/label      : label.c 
	tools          : lvmdiskscan.c 

Log message:
	Use new dev_open_readonly fn to prevent opening devices for read-write when not necessary.
	
	Before, we used vg_write_lock_held call to determnine the way a device is
	opened. Unfortunately, this opened many devices in RW mode when it was not
	really necessary. With the OPTIONS+="watch" rule used in the udev rules,
	this could fire numerous events while closing such devices (and it caused
	useless scans from within udev rules in return).
	
	A common bug we hit with this was with the lvremove command which was unable
	to remove the LV since it was being opened from within the udev rules. This
	patch should minimize such situations (at least with respect to LVM handling
	of devices).
	
	Though there's still a possibility someone will open a device 'outside' in
	parallel and fire the event based on the watch rule when closing a device
	once opened for RW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-luks.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-swap.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmdiskscan.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/lib/device/dev-io.c	2011/05/24 13:36:57	1.77
+++ LVM2/lib/device/dev-io.c	2011/05/28 09:48:14	1.78
@@ -431,9 +431,8 @@
 		}
 
 		if (dev->open_count && !need_excl) {
-			/* FIXME Ensure we never get here */
-			log_error(INTERNAL_ERROR "%s already opened read-only",
-				 dev_name(dev));
+			log_debug("%s already opened read-only. Upgrading "
+				  "to read-write.", dev_name(dev));
 			dev->open_count++;
 		}
 
@@ -540,20 +539,12 @@
 
 int dev_open_quiet(struct device *dev)
 {
-	int flags;
-
-	flags = vg_write_lock_held() ? O_RDWR : O_RDONLY;
-
-	return dev_open_flags(dev, flags, 1, 1);
+	return dev_open_flags(dev, O_RDWR, 1, 1);
 }
 
 int dev_open(struct device *dev)
 {
-	int flags;
-
-	flags = vg_write_lock_held() ? O_RDWR : O_RDONLY;
-
-	return dev_open_flags(dev, flags, 1, 0);
+	return dev_open_flags(dev, O_RDWR, 1, 0);
 }
 
 int dev_open_readonly(struct device *dev)
--- LVM2/lib/device/dev-luks.c	2010/08/19 23:08:18	1.1
+++ LVM2/lib/device/dev-luks.c	2011/05/28 09:48:14	1.2
@@ -23,7 +23,7 @@
 	char buf[LUKS_SIGNATURE_SIZE];
 	int ret = -1;
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		stack;
 		return -1;
 	}
--- LVM2/lib/device/dev-md.c	2010/07/09 15:34:42	1.20
+++ LVM2/lib/device/dev-md.c	2011/05/28 09:48:14	1.21
@@ -94,7 +94,7 @@
 	if (size < MD_RESERVED_SECTORS * 2)
 		return 0;
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		stack;
 		return -1;
 	}
--- LVM2/lib/device/dev-swap.c	2011/04/08 14:40:19	1.3
+++ LVM2/lib/device/dev-swap.c	2011/05/28 09:48:14	1.4
@@ -50,7 +50,7 @@
 		return -1;
 	}
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		stack;
 		return -1;
 	}
--- LVM2/lib/format1/disk-rep.c	2010/12/01 10:33:56	1.83
+++ LVM2/lib/format1/disk-rep.c	2011/05/28 09:48:15	1.84
@@ -415,7 +415,7 @@
 {
 	struct disk_list *dl;
 
-	if (!dev_open(dev))
+	if (!dev_open_readonly(dev))
 		return_NULL;
 
 	dl = __read_disk(fmt, dev, mem, vg_name);
--- LVM2/lib/format_pool/disk_rep.c	2010/12/20 14:20:52	1.18
+++ LVM2/lib/format_pool/disk_rep.c	2011/05/28 09:48:15	1.19
@@ -355,7 +355,7 @@
 {
 	struct pool_list *pl;
 
-	if (!dev_open(dev))
+	if (!dev_open_readonly(dev))
 		return_NULL;
 
 	if (!(pl = dm_pool_zalloc(mem, sizeof(*pl)))) {
--- LVM2/lib/format_text/format-text.c	2011/04/21 13:13:40	1.179
+++ LVM2/lib/format_text/format-text.c	2011/05/28 09:48:15	1.180
@@ -184,7 +184,7 @@
 		  PRIu64, mdac->area.start, mdac->area.size);
 	area = &mdac->area;
 
-	if (!dev_open(area->dev))
+	if (!dev_open_readonly(area->dev))
 		return_0;
 
 	if (!(mdah = raw_read_mda_header(fmt, area)))
@@ -462,7 +462,7 @@
 	int noprecommit = 0;
 	struct mda_header *mdah;
 
-	if (!dev_open(dev_area->dev))
+	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
 	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area)))
@@ -533,7 +533,7 @@
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	if (!dev_open(mdac->area.dev))
+	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
 	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0);
@@ -551,7 +551,7 @@
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	if (!dev_open(mdac->area.dev))
+	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
 	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1);
@@ -1218,7 +1218,7 @@
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
-		if (!dev_open(rl->dev_area.dev)) {
+		if (!dev_open_readonly(rl->dev_area.dev)) {
 			stack;
 			continue;
 		}
--- LVM2/lib/format_text/text_label.c	2011/02/18 14:34:41	1.39
+++ LVM2/lib/format_text/text_label.c	2011/05/28 09:48:15	1.40
@@ -302,7 +302,7 @@
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
-		if (!dev_open(mdac->area.dev)) {
+		if (!dev_open_readonly(mdac->area.dev)) {
 			mda_set_ignored(mda, 1);
 			stack;
 			continue;
--- LVM2/lib/label/label.c	2010/09/30 21:06:52	1.52
+++ LVM2/lib/label/label.c	2011/05/28 09:48:16	1.53
@@ -272,7 +272,7 @@
 		return 1;
 	}
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		stack;
 
 		if ((info = info_from_pvid(dev->pvid, 0)))
@@ -352,7 +352,7 @@
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		if ((info = info_from_pvid(dev->pvid, 0)))
 			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
 						      info->fmt->orphan_vg_name,
--- LVM2/tools/lvmdiskscan.c	2010/07/09 15:34:48	1.21
+++ LVM2/tools/lvmdiskscan.c	2011/05/28 09:48:16	1.22
@@ -72,7 +72,7 @@
 	char buffer;
 	uint64_t size;
 
-	if (!dev_open(dev)) {
+	if (!dev_open_readonly(dev)) {
 		return 0;
 	}
 	if (!dev_read(dev, UINT64_C(0), (size_t) 1, &buffer)) {


