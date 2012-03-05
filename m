From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Mar 2012 12:45:44 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20120305124544.26512.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-05 12:45:43

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Fix dm_task_get_name_unmangled to not unmangle already unmangled name.
	
	In 'auto' and 'hex' mode, these names are already unmangled on ioctl return.
	There's no point on trying to do that once again (actually it's a bug!).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.587&r2=1.588
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146

--- LVM2/WHATS_NEW_DM	2012/03/05 12:43:03	1.587
+++ LVM2/WHATS_NEW_DM	2012/03/05 12:45:43	1.588
@@ -1,5 +1,6 @@
 Version 1.02.74 - 
 ================================
+  Fix dm_task_get_name_unmangled to not unmangle already unmangled name.
   Check whether device names are properly mangled on ioctl return.
   Deactivation of failed thin check on thin pool returns success.
 
--- LVM2/libdm/libdm-common.c	2012/03/05 12:43:03	1.145
+++ LVM2/libdm/libdm-common.c	2012/03/05 12:45:43	1.146
@@ -588,9 +588,14 @@
 	const char *s = dm_task_get_name(dmt);
 	char buf[DM_NAME_LEN];
 	char *rs = NULL;
-	int r;
+	int r = 0;
 
-	if ((r = unmangle_name(s, strlen(s), buf, sizeof(buf),
+	/*
+	 * Unless the mode used is 'none', the name
+	 * is *already* unmangled on ioctl return!
+	 */
+	if (dm_get_name_mangling_mode() == DM_STRING_MANGLING_NONE &&
+	    (r = unmangle_name(s, strlen(s), buf, sizeof(buf),
 			       dm_get_name_mangling_mode())) < 0)
 		log_error("Failed to unmangle device name \"%s\".", s);
 	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))


