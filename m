From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 10:27:47 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20090519102747.21668.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 10:27:47

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix lvconvert check for multiple-segment mirrors (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/tools/lvconvert.c	2009/05/19 10:12:41	1.74
+++ LVM2/tools/lvconvert.c	2009/05/19 10:27:47	1.75
@@ -542,11 +542,10 @@
 	}
 
 	/*
-	 * FIXME This check used to precede mirror->mirror conversion
-	 * but didn't affect mirror->linear or linear->mirror. I do
-	 * not understand what is its intention, in fact.
+	 * For the most part, we cannot handle multi-segment mirrors. Bail out
+	 * early if we have encountered one.
 	 */
-	if (dm_list_size(&lv->segments) != 1) {
+	if ((lv->status & MIRRORED) && dm_list_size(&lv->segments) != 1) {
 		log_error("Logical volume %s has multiple "
 			  "mirror segments.", lv->name);
 		return 0;


