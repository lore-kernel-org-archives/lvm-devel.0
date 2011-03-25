From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 25 Mar 2011 21:56:28 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20110325215628.9451.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-25 21:56:28

Modified files:
	tools          : lvcreate.c 

Log message:
	cosmetic change - swapping one macro for another
	
	When I see 'seg_is_mirrored', I expect the argument to be an lv_segment.
	In this case, it is lvcreate_params.  Both structures, have a 'segtype'
	entry which the macro dereferences.  However, it just seems easier to
	understand if we do 'segtype_is_mirrored' instead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.229&r2=1.230

--- LVM2/tools/lvcreate.c	2011/02/18 14:47:31	1.229
+++ LVM2/tools/lvcreate.c	2011/03/25 21:56:28	1.230
@@ -346,7 +346,7 @@
 	lp->mirrors = 1;
 
 	/* Default to 2 mirrored areas if --type mirror */
-	if (seg_is_mirrored(lp))
+	if (segtype_is_mirrored(lp->segtype))
 		lp->mirrors = 2;
 
 	if (arg_count(cmd, mirrors_ARG)) {


