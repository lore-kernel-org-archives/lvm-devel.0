From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Jan 2011 23:11:41 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c
Message-ID: <20110119231141.22779.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-01-19 23:11:40

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 

Log message:
	If other process finishes (or aborts) pvmove operation and
	polling function cannot find any lv with PVMOVE flag, return
	success and do not print  "aborting" message.
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=602389

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1885&r2=1.1886
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2011/01/19 23:09:31	1.1885
+++ LVM2/WHATS_NEW	2011/01/19 23:11:39	1.1886
@@ -2,6 +2,7 @@
 ===================================
   Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
   Fix possible clvmd DLM lockspace increasing reference count.
+  Do not fail polling if pvmove finished in another process.
 
 Version 2.02.81 - 17th January 2011
 ===================================
--- LVM2/tools/polldaemon.c	2011/01/12 20:42:51	1.42
+++ LVM2/tools/polldaemon.c	2011/01/19 23:11:39	1.43
@@ -193,8 +193,16 @@
 			return 0;
 		}
 
-		if (!(lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
-							parms->lv_type))) {
+		lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid, parms->lv_type);
+
+		if (!lv && parms->lv_type == PVMOVE) {
+			log_print("%s: no pvmove in progress - already finished or aborted.",
+				  name);
+			unlock_and_free_vg(cmd, vg, vg->name);
+			return 1;
+		}
+
+		if (!lv) {
 			log_error("ABORTING: Can't find LV in %s for %s",
 				  vg->name, name);
 			unlock_and_free_vg(cmd, vg, vg->name);


