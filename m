From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Sep 2007 16:02:47 -0000
Subject: LVM2 ./WHATS_NEW lib/datastruct/str_list.c lib ...
Message-ID: <20070917160247.30018.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-09-17 16:02:46

Modified files:
	.              : WHATS_NEW 
	lib/datastruct : str_list.c 
	lib/metadata   : metadata.c 

Log message:
	Fix strdup memory leak in str_list_dup().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.706&r2=1.707
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/WHATS_NEW	2007/09/12 16:54:23	1.706
+++ LVM2/WHATS_NEW	2007/09/17 16:02:46	1.707
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Fix strdup memory leak in str_list_dup().
   Avoid static link failure with some SELinux libraries.
   Diagnose invalid PE values given on the pvmove command line (64-bit systems).
   Include strerror string in dev_open_flags' stat failure message.
--- LVM2/lib/datastruct/str_list.c	2007/08/20 20:55:24	1.8
+++ LVM2/lib/datastruct/str_list.c	2007/09/17 16:02:46	1.9
@@ -74,7 +74,7 @@
 	list_init(sllnew);
 
 	list_iterate_items(sl, sllold) {
-		if (!str_list_add(mem, sllnew, strdup(sl->str))) {
+		if (!str_list_add(mem, sllnew, dm_pool_strdup(mem, sl->str))) {
 			stack;
 			return 0;
 		}
--- LVM2/lib/metadata/metadata.c	2007/08/28 16:14:48	1.135
+++ LVM2/lib/metadata/metadata.c	2007/09/17 16:02:46	1.136
@@ -908,6 +908,7 @@
 		return NULL;
 	}
 
+	/* FIXME Can fail when no PV mda */
 	if (!pv->vg_name[0]) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		return NULL;


