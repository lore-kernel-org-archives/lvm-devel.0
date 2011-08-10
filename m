From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 10 Aug 2011 16:44:18 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110810164418.16737.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-10 16:44:18

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Fix compiler warning.
	
	Compiler complaining that meta_lv could be used uninitialized.  (Not true
	because it is protected by 'clear_metadata'.)  I switched to using 'lv->vg',
	as it makes no difference to vg_[write|commit].

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.270&r2=1.271

--- LVM2/lib/metadata/lv_manip.c	2011/08/05 09:21:13	1.270
+++ LVM2/lib/metadata/lv_manip.c	2011/08/10 16:44:17	1.271
@@ -2389,7 +2389,7 @@
 		/*
 		 * We must clear the metadata areas upon creation.
 		 */
-		if (!vg_write(meta_lv->vg) || !vg_commit(meta_lv->vg))
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 			return_0;
 
 		for (s = 0; s < seg->area_count; s++) {


