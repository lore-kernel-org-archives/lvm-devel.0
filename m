From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:17:13 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100114101713.1131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:17:13

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Cleanup const compiler warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205

--- LVM2/lib/metadata/lv_manip.c	2010/01/14 10:09:42	1.204
+++ LVM2/lib/metadata/lv_manip.c	2010/01/14 10:17:12	1.205
@@ -852,8 +852,8 @@
 
 static int _comp_area(const void *l, const void *r)
 {
-	const struct pv_area *lhs = *((const struct pv_area **) l);
-	const struct pv_area *rhs = *((const struct pv_area **) r);
+	const struct pv_area *lhs = *((const struct pv_area * const *) l);
+	const struct pv_area *rhs = *((const struct pv_area * const *) r);
 
 	if (lhs->count < rhs->count)
 		return 1;


