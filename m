From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:13:55 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20101025131355.12711.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:13:53

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-string.c 

Log message:
	Use const pointer for return value of dm_basename
	
	Fix return pointer to const as it is created from passed input const pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.417&r2=1.418
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW_DM	2010/10/15 01:10:27	1.417
+++ LVM2/WHATS_NEW_DM	2010/10/25 13:13:53	1.418
@@ -1,5 +1,6 @@
 Version 1.02.56 - 
 =====================================
+  Fix API for dm_basename() and return const pointer for const input pointer.
   Add --setuuid to dmsetup rename.
   Add dm_task_set_newuuid to set uuid of mapped device post-creation.
 
--- LVM2/libdm/libdevmapper.h	2010/10/15 01:10:28	1.127
+++ LVM2/libdm/libdevmapper.h	2010/10/25 13:13:53	1.128
@@ -955,7 +955,7 @@
 /*
  * Returns pointer to the last component of the path.
  */
-char *dm_basename(const char *path);
+const char *dm_basename(const char *path);
 
 /**************************
  * file/stream manipulation
--- LVM2/libdm/libdm-string.c	2010/07/09 15:34:47	1.12
+++ LVM2/libdm/libdm-string.c	2010/10/25 13:13:53	1.13
@@ -123,11 +123,11 @@
 	return n;
 }
 
-char *dm_basename(const char *path)
+const char *dm_basename(const char *path)
 {
-	char *p = strrchr(path, '/');
+	const char *p = strrchr(path, '/');
 
-	return p ? p + 1 : (char *) path;
+	return p ? p + 1 : path;
 }
 
 int dm_asprintf(char **result, const char *format, ...)


