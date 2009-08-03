From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 18:31:53 -0000
Subject: LVM2/lib/activate fs.c
Message-ID: <20090803183153.21886.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 18:31:53

Modified files:
	lib/activate   : fs.c 

Log message:
	Add warnings to check udev did what it was meant to.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/lib/activate/fs.c	2008/12/19 14:22:48	1.44
+++ LVM2/lib/activate/fs.c	2009/08/03 18:31:53	1.45
@@ -194,9 +194,14 @@
 		return 0;
 	}
 
-	if (lstat(lv_path, &buf) || !S_ISLNK(buf.st_mode)) {
-		if (errno == ENOENT)
-			return 1;
+	if (lstat(lv_path, &buf) && errno == ENOENT)
+		return 1;
+	else if (dm_udev_get_sync_support())
+		log_warn("The link %s should have been removed by udev "
+			 "but it is still present. Falling back to "
+			 "direct link removal.", lv_path);
+
+	if (!S_ISLNK(buf.st_mode)) {
 		log_error("%s not symbolic link - not removing", lv_path);
 		return 0;
 	}


