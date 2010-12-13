From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Dec 2010 12:44:11 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20101213124411.17844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-12-13 12:44:10

Modified files:
	libdm          : libdm-common.c 

Log message:
	HAVE_SELINUX again

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/libdm/libdm-common.c	2010/12/13 12:30:04	1.105
+++ LVM2/libdm/libdm-common.c	2010/12/13 12:44:09	1.106
@@ -387,10 +387,10 @@
 	return 1;
 }
 
+#ifdef HAVE_SELINUX
 static int _selabel_lookup(const char *path, mode_t mode,
 			   security_context_t *scontext)
 {
-#ifdef HAVE_SELINUX
 #ifdef HAVE_SELINUX_LABEL_H
 	if (!_selabel_handle &&
 	    !(_selabel_handle = selabel_open(SELABEL_CTX_FILE, NULL, 0))) {
@@ -408,9 +408,9 @@
 		return 0;
 	}
 #endif
-#endif
 	return 1;
 }
+#endif
 
 int dm_prepare_selinux_context(const char *path, mode_t mode)
 {


