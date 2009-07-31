From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 16:57:09 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090731165709.31419.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 16:57:08

Modified files:
	libdm          : libdm-common.c 

Log message:
	another fixme

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/libdm/libdm-common.c	2009/07/31 15:53:12	1.67
+++ LVM2/libdm/libdm-common.c	2009/07/31 16:57:06	1.68
@@ -818,6 +818,7 @@
 
 static int _get_cookie_sem(uint32_t cookie, int *semid)
 {
+	/* FIXME Ensure cookie has COOKIE_MAGIC prefix */
 	if ((*semid = semget((key_t) cookie, 1, 0)) >= 0)
 		return 1;
 


