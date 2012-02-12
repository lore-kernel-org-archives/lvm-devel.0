From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2012 20:17:13 -0000
Subject: LVM2/lib/activate fs.c
Message-ID: <20120212201713.15967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-12 20:17:12

Modified files:
	lib/activate   : fs.c 

Log message:
	give standard error message if lstat fails unexpectedly

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/lib/activate/fs.c	2012/02/08 10:43:42	1.65
+++ LVM2/lib/activate/fs.c	2012/02/12 20:17:12	1.66
@@ -225,7 +225,6 @@
 static int _rm_link(const char *dev_dir, const char *vg_name,
 		    const char *lv_name, int check_udev)
 {
-	int r;
 	struct stat buf;
 	static char lv_path[PATH_MAX];
 
@@ -235,14 +234,17 @@
 		return 0;
 	}
 
-	if ((r = lstat(lv_path, &buf)) && errno == ENOENT)
-		return 1;
-	else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
+	if (lstat(lv_path, &buf)) {
+		if (errno == ENOENT)
+			return 1;
+		log_sys_error("lstat", lv_path);
+		return 0;
+	} else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
 
-	if (r || !S_ISLNK(buf.st_mode)) {
+	if (!S_ISLNK(buf.st_mode)) {
 		log_error("%s not symbolic link - not removing", lv_path);
 		return 0;
 	}


