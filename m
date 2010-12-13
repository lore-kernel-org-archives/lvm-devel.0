From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Dec 2010 12:30:06 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20101213123006.26328.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-12-13 12:30:05

Modified files:
	libdm          : libdm-common.c 

Log message:
	#ifdef HAVE_SELINUX and #ifdef HAVE_SELINUX_LABEL_H

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/libdm/libdm-common.c	2010/12/13 12:18:38	1.104
+++ LVM2/libdm/libdm-common.c	2010/12/13 12:30:04	1.105
@@ -390,6 +390,7 @@
 static int _selabel_lookup(const char *path, mode_t mode,
 			   security_context_t *scontext)
 {
+#ifdef HAVE_SELINUX
 #ifdef HAVE_SELINUX_LABEL_H
 	if (!_selabel_handle &&
 	    !(_selabel_handle = selabel_open(SELABEL_CTX_FILE, NULL, 0))) {
@@ -401,12 +402,13 @@
 		log_error("selabel_lookup failed: %s", strerror(errno));
 		return 0;
 	}
-#elif HAVE_SELINUX
+#else
 	if (matchpathcon(path, mode, scontext)) {
 		log_error("matchpathcon failed: %s", strerror(errno));
 		return 0;
 	}
 #endif
+#endif
 	return 1;
 }
 


