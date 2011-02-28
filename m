From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2011 19:35:10 -0000
Subject: LVM2 ./WHATS_NEW tools/pvremove.c
Message-ID: <20110228193510.7398.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-28 19:35:10

Modified files:
	.              : WHATS_NEW 
	tools          : pvremove.c 

Log message:
	Improve pvremove error message when PV belongs to a VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1929&r2=1.1930
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2011/02/28 13:19:02	1.1929
+++ LVM2/WHATS_NEW	2011/02/28 19:35:09	1.1930
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Improve pvremove error message when PV belongs to a VG.
   Extend normal policy to allow mirror logs on same PVs as images if necessary.
   Improve cling policy to recognise PVs already used during the transaction.
   Improve normal allocation algorithm to include clinging to existing areas.
--- LVM2/tools/pvremove.c	2011/02/21 12:16:00	1.32
+++ LVM2/tools/pvremove.c	2011/02/28 19:35:10	1.33
@@ -64,8 +64,8 @@
 	/* Allow partial & exported VGs to be destroyed. */
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
-		log_error("Can't pvremove physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
+		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
+		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
 		return 0;
 	}
 


