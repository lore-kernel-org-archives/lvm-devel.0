From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:59:20 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20120208125920.28523.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:59:20

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use dm_asprintf to simplify code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.541&r2=1.542
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/WHATS_NEW_DM	2012/02/08 11:25:09	1.541
+++ LVM2/WHATS_NEW_DM	2012/02/08 12:59:19	1.542
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Simplify dm_task_set_geometry() and use dm_asprintf().
   Set all parameters to 0 for dm_get_next_target() for NULL return.
   Fix fd resource leak in error path for _udev_notify_sem_create().
   Leave space for '\0' for readline() call in _sysfs_get_kernel_name().
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/08 11:25:10	1.133
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/08 12:59:20	1.134
@@ -769,16 +769,11 @@
 	return 1;
 }
 
-int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start)
+int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
+			 const char *sectors, const char *start)
 {
-	size_t len = strlen(cylinders) + 1 + strlen(heads) + 1 + strlen(sectors) + 1 + strlen(start) + 1;
-
-	if (!(dmt->geometry = dm_malloc(len))) {
-		log_error("dm_task_set_geometry: dm_malloc failed");
-		return 0;
-	}
-
-	if (sprintf(dmt->geometry, "%s %s %s %s", cylinders, heads, sectors, start) < 0) {
+	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
+			cylinders, heads, sectors, start) < 0) {
 		log_error("dm_task_set_geometry: sprintf failed");
 		return 0;
 	}


