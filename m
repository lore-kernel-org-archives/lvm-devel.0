From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 19:10:52 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111003191052.5263.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 19:10:52

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Missed rename pool->thin_pool
	
	Fix compilation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/metadata/thin_manip.c	2011/10/03 18:39:17	1.5
+++ LVM2/lib/metadata/thin_manip.c	2011/10/03 19:10:52	1.6
@@ -97,7 +97,7 @@
 
 	if (!seg_is_thin_pool(thin_pool_seg)) {
 		log_error("Segment in %s is not a thin pool segment.",
-			  pool_seg->lv->name);
+			  thin_pool_seg->lv->name);
 		return 0;
 	}
 


