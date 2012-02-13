From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 10:49:29 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20120213104929.6324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 10:49:28

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Do not write to -1 buffer address
	
	In case of zero bytes would be read from sysfs, it would store '\0' on
	temp_buf[-1] address.
	
	Simplify some buffer length calculation and use strcpy if we've just
	checked string fits in give buffer.
	
	Replace jump label error: with bad: commonly used in libdm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.551&r2=1.552
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/WHATS_NEW_DM	2012/02/13 00:23:21	1.551
+++ LVM2/WHATS_NEW_DM	2012/02/13 10:49:28	1.552
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Fix potential risk of writing in front of buffer in _sysfs_get_dm_name().
 
 Version 1.02.70 - 12th February 2012
 ====================================
--- LVM2/libdm/libdm-common.c	2012/02/08 11:07:17	1.136
+++ LVM2/libdm/libdm-common.c	2012/02/13 10:49:28	1.137
@@ -1191,19 +1191,18 @@
 	char *sysfs_path, *temp_buf;
 	FILE *fp = NULL;
 	int r = 0;
+	size_t len;
 
 	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
 	    !(temp_buf = dm_malloc(PATH_MAX))) {
 		log_error("_sysfs_get_dm_name: failed to allocate temporary buffers");
-		if (sysfs_path)
-			dm_free(sysfs_path);
-		return 0;
+		goto bad;
 	}
 
 	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32
 			"/dm/name", _sysfs_dir, major, minor) < 0) {
 		log_error("_sysfs_get_dm_name: dm_snprintf failed");
-		goto error;
+		goto bad;
 	}
 
 	if (!(fp = fopen(sysfs_path, "r"))) {
@@ -1211,23 +1210,25 @@
 			log_sys_error("fopen", sysfs_path);
 		else
 			log_sys_debug("fopen", sysfs_path);
-		goto error;
+		goto bad;
 	}
 
 	if (!fgets(temp_buf, PATH_MAX, fp)) {
 		log_sys_error("fgets", sysfs_path);
-		goto error;
+		goto bad;
 	}
-	temp_buf[strlen(temp_buf) - 1] = '\0';
 
-	if (buf_size < strlen(temp_buf) + 1) {
+	len = strlen(temp_buf);
+
+	if (len > buf_size) {
 		log_error("_sysfs_get_dm_name: supplied buffer too small");
-		goto error;
+		goto bad;
 	}
 
-	strncpy(buf, temp_buf, buf_size);
+	temp_buf[len ? len - 1 : 0] = '\0'; /* \n */
+	strcpy(buf, temp_buf);
 	r = 1;
-error:
+bad:
 	if (fp && fclose(fp))
 		log_sys_error("fclose", sysfs_path);
 
@@ -1241,19 +1242,19 @@
 {
 	char *sysfs_path, *temp_buf, *name;
 	ssize_t size;
+	size_t len;
+	int r = 0;
 
 	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
 	    !(temp_buf = dm_malloc(PATH_MAX))) {
 		log_error("_sysfs_get_kernel_name: failed to allocate temporary buffers");
-		if (sysfs_path)
-			dm_free(sysfs_path);
-		return 0;
+		goto bad;
 	}
 
 	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
 			_sysfs_dir, major, minor) < 0) {
 		log_error("_sysfs_get_kernel_name: dm_snprintf failed");
-		goto error;
+		goto bad;
 	}
 
 	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX - 1)) < 0) {
@@ -1261,30 +1262,29 @@
 			log_sys_error("readlink", sysfs_path);
 		else
 			log_sys_debug("readlink", sysfs_path);
-		goto error;
+		goto bad;
 	}
 	temp_buf[size] = '\0';
 
 	if (!(name = strrchr(temp_buf, '/'))) {
 		log_error("Could not locate device kernel name in sysfs path %s", temp_buf);
-		goto error;
+		goto bad;
 	}
 	name += 1;
+	len = size - (name - temp_buf) + 1;
 
-	if (buf_size < strlen(name) + 1) {
+	if (len > buf_size) {
 		log_error("_sysfs_get_kernel_name: output buffer too small");
-		goto error;
+		goto bad;
 	}
 
-	strncpy(buf, name, buf_size);
+	strcpy(buf, name);
+	r = 1;
+bad:
 	dm_free(sysfs_path);
 	dm_free(temp_buf);
-	return 1;
 
-error:
-	dm_free(sysfs_path);
-	dm_free(temp_buf);
-	return 0;
+	return r;
 }
 
 int dm_device_get_name(uint32_t major, uint32_t minor, int prefer_kernel_name,


