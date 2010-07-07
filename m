From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2010 21:30:09 -0000
Subject: LVM2/tools pvchange.c vgextend.c
Message-ID: <20100707213009.27381.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-07 21:30:08

Modified files:
	tools          : pvchange.c vgextend.c 

Log message:
	Shorten prompt for pvchange and vgextend.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/tools/pvchange.c	2010/07/07 19:14:58	1.81
+++ LVM2/tools/pvchange.c	2010/07/07 21:30:07	1.82
@@ -124,10 +124,9 @@
 	} else if (arg_count(cmd, metadataignore_ARG)) {
 		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 		    (arg_count(cmd, force_ARG) == PROMPT) &&
-		    yes_no_prompt("Setting metadataignore on %s will override "
-				  "preferred number of copies of VG %s "
-				  "metadata.\nAre you sure? [y/n]: ",
-				  pv_name, pv_vg_name(pv)) == 'n') {
+		    yes_no_prompt("Override preferred number of copies "
+				  "of VG %s metadata? [y/n]: ",
+				  pv_vg_name(pv)) == 'n') {
 			log_error("Physical volume %s not changed", pv_name);
 			goto out;
 		}
--- LVM2/tools/vgextend.c	2010/07/07 19:14:58	1.58
+++ LVM2/tools/vgextend.c	2010/07/07 21:30:07	1.59
@@ -62,9 +62,8 @@
 	if (arg_count(cmd, metadataignore_ARG) &&
 	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 	    (pp.force == PROMPT) &&
-	    yes_no_prompt("Setting metadataignore will override "
-			  "preferred number of copies of VG %s "
-			  "metadata.\nAre you sure? [y/n]: ",
+	    yes_no_prompt("Override preferred number of copies "
+			  "of VG %s metadata? [y/n]: ",
 			  vg_name) == 'n') {
 		log_error("Volume group %s not changed", vg_name);
 		goto_bad;


