From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:47:18 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20120125214718.29653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:47:18

Modified files:
	libdm          : libdm-common.c 

Log message:
	Fix resource leak of file handle
	
	Introduces when added dm_device_get_name.
	Close file handle in all error paths.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/libdm/libdm-common.c	2012/01/17 14:36:58	1.133
+++ LVM2/libdm/libdm-common.c	2012/01/25 21:47:18	1.134
@@ -1189,7 +1189,8 @@
 static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
 	char *sysfs_path, *temp_buf;
-	FILE *fp;
+	FILE *fp = NULL;
+	int r = 0;
 
 	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
 	    !(temp_buf = dm_malloc(PATH_MAX))) {
@@ -1219,23 +1220,21 @@
 	}
 	temp_buf[strlen(temp_buf) - 1] = '\0';
 
-	if (fclose(fp))
-		log_sys_error("fclose", sysfs_path);
-
 	if (buf_size < strlen(temp_buf) + 1) {
 		log_error("_sysfs_get_dm_name: supplied buffer too small");
 		goto error;
 	}
 
 	strncpy(buf, temp_buf, buf_size);
-	dm_free(sysfs_path);
-	dm_free(temp_buf);
-	return 1;
-
+	r = 1;
 error:
+	if (fp && fclose(fp))
+		log_sys_error("fclose", sysfs_path);
+
 	dm_free(sysfs_path);
 	dm_free(temp_buf);
-	return 0;
+
+	return r;
 }
 
 static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)


