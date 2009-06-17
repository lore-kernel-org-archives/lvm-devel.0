From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jun 2009 20:55:30 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/activate/d ...
Message-ID: <20090617205530.3379.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-17 20:55:25

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/activate   : dev_manager.c 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 

Log message:
	Fix backward compatibility for major:minor query.
	
	Is an application uses query and set major:minor
	to device, it should not fallback to default major by default.
	
	Add new function whoich allows that (and use it in lvm2).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1152&r2=1.1153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.277&r2=1.278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2009/06/15 15:09:02	1.1152
+++ LVM2/WHATS_NEW	2009/06/17 20:55:24	1.1153
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Explicitly request fallback to default major number in device mapper.
   Ignore suspended devices during repair.
   Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
   Suggest use lvchange --resync when up converting not yet synced mirror.
--- LVM2/WHATS_NEW_DM	2009/06/15 12:29:41	1.277
+++ LVM2/WHATS_NEW_DM	2009/06/17 20:55:24	1.278
@@ -1,5 +1,6 @@
 Version 1.02.33 -
 ===============================
+  Do not fallback to default major number, provide new function instead (1.02.31)
   Do not fork daemon when dmeventd cannot be found.
   Add crypt target handling to libdevmapper node.
   Add splitname command to dmsetup.
--- LVM2/lib/activate/dev_manager.c	2009/06/01 12:43:32	1.152
+++ LVM2/lib/activate/dev_manager.c	2009/06/17 20:55:24	1.153
@@ -111,10 +111,8 @@
 	if (event_nr)
 		dm_task_set_event_nr(dmt, *event_nr);
 
-	if (major) {
-		dm_task_set_major(dmt, major);
-		dm_task_set_minor(dmt, minor);
-	}
+	if (major)
+		dm_task_set_major_minor(dmt, major, minor, 1);
 
 	return dmt;
 }
@@ -171,7 +169,7 @@
 		return 0;
 	}
 
-	if (!dm_task_set_major(dmt, MAJOR(dev)) || !dm_task_set_minor(dmt, MINOR(dev)))
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev), MINOR(dev), 1))
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
--- LVM2/libdm/.exported_symbols	2009/06/09 16:10:24	1.36
+++ LVM2/libdm/.exported_symbols	2009/06/17 20:55:24	1.37
@@ -24,6 +24,7 @@
 dm_task_set_event_nr
 dm_task_set_major
 dm_task_set_minor
+dm_task_set_major_minor
 dm_task_set_sector
 dm_task_set_message
 dm_task_set_uid
--- LVM2/libdm/libdevmapper.h	2009/06/09 16:10:24	1.89
+++ LVM2/libdm/libdevmapper.h	2009/06/17 20:55:24	1.90
@@ -145,6 +145,7 @@
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
 int dm_task_set_minor(struct dm_task *dmt, int minor);
 int dm_task_set_major(struct dm_task *dmt, int major);
+int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow_default_major_fallback);
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
--- LVM2/libdm/libdm-common.c	2009/01/07 12:17:40	1.64
+++ LVM2/libdm/libdm-common.c	2009/06/17 20:55:24	1.65
@@ -118,6 +118,7 @@
 	dmt->type = type;
 	dmt->minor = -1;
 	dmt->major = -1;
+	dmt->allow_default_major_fallback = 1;
 	dmt->uid = DM_DEVICE_UID;
 	dmt->gid = DM_DEVICE_GID;
 	dmt->mode = DM_DEVICE_MODE;
@@ -190,6 +191,7 @@
 int dm_task_set_major(struct dm_task *dmt, int major)
 {
 	dmt->major = major;
+	dmt->allow_default_major_fallback = 0;
 
 	return 1;
 }
@@ -201,6 +203,16 @@
 	return 1;
 }
 
+int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor,
+			    int allow_default_major_fallback)
+{
+	dmt->major = major;
+	dmt->minor = minor;
+	dmt->allow_default_major_fallback = allow_default_major_fallback;
+
+	return 1;
+}
+
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid)
 {
 	dmt->uid = uid;
--- LVM2/libdm/ioctl/libdm-iface.c	2009/04/10 09:56:58	1.57
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/06/17 20:55:25	1.58
@@ -1335,7 +1335,8 @@
 			goto bad;
 		}
 
-		if (!_dm_multiple_major_support && dmt->major != _dm_device_major) {
+		if (!_dm_multiple_major_support && dmt->allow_default_major_fallback &&
+		    dmt->major != _dm_device_major) {
 			log_verbose("Overriding major number of %" PRIu32 
 				    " with %" PRIu32 " for persistent device.",
 				    dmt->major, _dm_device_major);
--- LVM2/libdm/ioctl/libdm-targets.h	2008/09/18 18:34:53	1.23
+++ LVM2/libdm/ioctl/libdm-targets.h	2009/06/17 20:55:25	1.24
@@ -41,6 +41,7 @@
 	uint32_t event_nr;
 	int major;
 	int minor;
+	int allow_default_major_fallback;
 	uid_t uid;
 	gid_t gid;
 	mode_t mode;


