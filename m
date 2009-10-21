From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Oct 2009 22:19:39 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20091021221939.30572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-10-21 22:19:39

Modified files:
	tools          : lvconvert.c 

Log message:
	Clarify message:
	"  Mirror status: 1/2 images failed."
	
	Half of an image?  Half of the images?  No, 1 of 2 images.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/tools/lvconvert.c	2009/09/30 18:15:06	1.93
+++ LVM2/tools/lvconvert.c	2009/10/21 22:19:39	1.94
@@ -584,7 +584,7 @@
 		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
 			return_0;
 		lp->mirrors -= failed_mirrors;
-		log_error("Mirror status: %d/%d images failed.",
+		log_error("Mirror status: %d of %d images failed.",
 			  failed_mirrors, existing_mirrors);
 		old_pvh = lp->pvh;
 		if (!(lp->pvh = _failed_pv_list(lv->vg)))


