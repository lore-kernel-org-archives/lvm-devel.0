From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 14:39:25 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20120213143925.3303.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 14:39:24

Modified files:
	libdm          : libdm-common.c 

Log message:
	Fix missing temp_buf init for error path
	
	In previous commit this was missing, also deallocate in reversed order.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/libdm/libdm-common.c	2012/02/13 10:49:28	1.137
+++ LVM2/libdm/libdm-common.c	2012/02/13 14:39:24	1.138
@@ -1188,7 +1188,7 @@
 
 static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
-	char *sysfs_path, *temp_buf;
+	char *sysfs_path, *temp_buf = NULL;
 	FILE *fp = NULL;
 	int r = 0;
 	size_t len;
@@ -1232,15 +1232,15 @@
 	if (fp && fclose(fp))
 		log_sys_error("fclose", sysfs_path);
 
-	dm_free(sysfs_path);
 	dm_free(temp_buf);
+	dm_free(sysfs_path);
 
 	return r;
 }
 
 static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
-	char *sysfs_path, *temp_buf, *name;
+	char *name, *sysfs_path, *temp_buf = NULL;
 	ssize_t size;
 	size_t len;
 	int r = 0;
@@ -1281,8 +1281,8 @@
 	strcpy(buf, name);
 	r = 1;
 bad:
-	dm_free(sysfs_path);
 	dm_free(temp_buf);
+	dm_free(sysfs_path);
 
 	return r;
 }


