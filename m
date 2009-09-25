From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Sep 2009 11:58:01 -0000
Subject: LVM2 lib/activate/fs.c libdm/libdevmapper.h li ...
Message-ID: <20090925115801.11275.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-25 11:58:01

Modified files:
	lib/activate   : fs.c 
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use the same default umask for /dev dirs (DM_DEV_DIR_UMASK).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/lib/activate/fs.c	2009/08/05 09:12:44	1.47
+++ LVM2/lib/activate/fs.c	2009/09/25 11:58:00	1.48
@@ -29,6 +29,7 @@
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
+	mode_t old_umask;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
@@ -41,10 +42,14 @@
 		return 1;
 
 	log_very_verbose("Creating directory %s", vg_path);
+
+	old_umask = umask(DM_DEV_DIR_UMASK);
 	if (mkdir(vg_path, 0777)) {
 		log_sys_error("mkdir", vg_path);
+		umask(old_umask);
 		return 0;
 	}
+	umask(old_umask);
 
 	return 1;
 }
--- LVM2/libdm/libdevmapper.h	2009/08/06 15:04:30	1.96
+++ LVM2/libdm/libdevmapper.h	2009/09/25 11:58:00	1.97
@@ -1026,4 +1026,6 @@
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
+#define DM_DEV_DIR_UMASK 0022
+
 #endif				/* LIB_DEVICE_MAPPER_H */
--- LVM2/libdm/ioctl/libdm-iface.c	2009/08/06 15:02:01	1.61
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/09/25 11:58:00	1.62
@@ -234,7 +234,7 @@
 	if (!major)
 		return 0;
 
-	old_umask = umask(0022);
+	old_umask = umask(DM_DEV_DIR_UMASK);
 	ret = dm_create_dir(dm_dir());
 	umask(old_umask);
 


