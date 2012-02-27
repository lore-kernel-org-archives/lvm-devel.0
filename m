From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:06:59 -0000
Subject: LVM2/tools vgreduce.c vgremove.c
Message-ID: <20120227100659.15185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:06:58

Modified files:
	tools          : vgreduce.c vgremove.c 

Log message:
	Make force_t enum usage obvious

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/tools/vgreduce.c	2012/02/15 12:30:46	1.115
+++ LVM2/tools/vgreduce.c	2012/02/27 10:06:58	1.116
@@ -104,7 +104,7 @@
 			if (!lv_is_visible(lv))
 				continue;
 			log_warn("Removing partial LV %s.", lv->name);
-			if (!lv_remove_with_dependencies(cmd, lv, 1, 0))
+			if (!lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0))
 				return_0;
 			goto restart;
 		}
--- LVM2/tools/vgremove.c	2010/07/09 15:34:48	1.62
+++ LVM2/tools/vgremove.c	2012/02/27 10:06:58	1.63
@@ -29,7 +29,7 @@
 
 	lv_count = vg_visible_lvs(vg);
 
-	force = arg_count(cmd, force_ARG);
+	force = (force_t) arg_count(cmd, force_ARG);
 	if (lv_count) {
 		if (force == PROMPT) {
 			if ((missing = vg_missing_pv_count(vg)))


