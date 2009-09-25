From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 18:13:18 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090925181318.28188.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 18:13:17

Modified files:
	libdm          : libdm-common.c 

Log message:
	remove unused var & rename fn

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/libdm/libdm-common.c	2009/09/25 18:08:04	1.82
+++ LVM2/libdm/libdm-common.c	2009/09/25 18:13:17	1.83
@@ -187,7 +187,7 @@
 /*
  * Find the name associated with a given device number by scanning _dm_dir.
  */
-static char *_translate_name(dev_t st_rdev, const char *devname)
+static char *_find_dm_name_of_device(dev_t st_rdev)
 {
 	const char *name;
 	char path[PATH_MAX];
@@ -257,13 +257,13 @@
 		/*
 		 * If supplied path points to same device as last component
 		 * under /dev/mapper, use that name directly.  Otherwise call
-		 * _translate_name() to scan _dm_dir for a match.
+		 * _find_dm_name_of_device() to scan _dm_dir for a match.
 		 */
 		snprintf(path, sizeof(path), "%s/%s", _dm_dir, pos + 1);
 
 		if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
 			name = pos + 1;
-		else if ((new_name = _translate_name(st1.st_rdev, pos + 1)))
+		else if ((new_name = _find_dm_name_of_device(st1.st_rdev)))
 			name = new_name;
 		else {
 			log_error("Device %s not found", name);


