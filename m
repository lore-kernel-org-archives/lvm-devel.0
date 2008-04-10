From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 18:53:36 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20080410185336.18841.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 18:53:36

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/mirror/mirrored.c	2008/04/10 17:09:31	1.54
+++ LVM2/lib/mirror/mirrored.c	2008/04/10 18:53:36	1.55
@@ -373,7 +373,7 @@
 
 	/*
 	 * Check only for modules if atttributes requested and no previous check.
-	 * FIXME: need better check
+	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
 		if (!_mirror_attributes && module_present("cmirror"))


