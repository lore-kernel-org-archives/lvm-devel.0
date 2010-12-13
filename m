From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Dec 2010 12:18:39 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20101213121839.20950.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-12-13 12:18:38

Modified files:
	libdm          : libdm-common.c 

Log message:
	Missing #elif HAVE_SELINUX

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/libdm/libdm-common.c	2010/12/13 10:43:58	1.103
+++ LVM2/libdm/libdm-common.c	2010/12/13 12:18:38	1.104
@@ -401,7 +401,7 @@
 		log_error("selabel_lookup failed: %s", strerror(errno));
 		return 0;
 	}
-#else
+#elif HAVE_SELINUX
 	if (matchpathcon(path, mode, scontext)) {
 		log_error("matchpathcon failed: %s", strerror(errno));
 		return 0;


