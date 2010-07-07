From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2010 19:02:51 -0000
Subject: LVM2 ./WHATS_NEW tools/pvchange.c tools/vgextend.c
Message-ID: <20100707190251.31639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-07 19:02:50

Modified files:
	.              : WHATS_NEW 
	tools          : pvchange.c vgextend.c 

Log message:
	Add prompt if using --metadataignore argument with vgmetadatacopies.
	
	When using vgmetadatacopies value other than "umanaged" (0), prompt
	the user if the usage of --metadataignore would change the value of
	vgmetadatacopies.  The main 2 cases are:
	1) pvchange --metadataignore
	2) vgextend --metadataignore
	
	We leave the prompt check in the tools, and do not change anything
	if the user says 'n'.
	
	Examples:
	vgextend --metadataignore y vgtest /dev/loop0
	Setting metadataignore will override preferred number of copies of VG vgtest metadata.
	Are you sure? [y/n]: y
	No physical volume label read from /dev/loop0
	Physical volume "/dev/loop0" successfully created
	Volume group "vgtest" successfully extended
	
	pvchange --metadataignore y /dev/loop3
	Setting metadataignore on /dev/loop3 will override preferred number of copies of VG vgtest metadata.
	Are you sure? [y/n]: y
	WARNING: Changing preferred number of copies of VG vgtest metadata from 3 to 2
	Physical volume "/dev/loop3" changed
	1 physical volume changed / 0 physical volumes not changed
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1657&r2=1.1658
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2010/07/07 02:53:16	1.1657
+++ LVM2/WHATS_NEW	2010/07/07 19:02:50	1.1658
@@ -1,5 +1,7 @@
 Version 2.02.71 -
 ===============================
+  Prompt if metadataignore with vgextend or pvchange would adjust vg_mda_copies.
+  Adjust vg_mda_copies if metadataignore given with vgextend or pvchange.
   Adjust auto-metadata repair and caching logic to try to cope with empty mdas.
 
 Version 2.02.70 - 6th July 2010
--- LVM2/tools/pvchange.c	2010/06/29 21:32:44	1.79
+++ LVM2/tools/pvchange.c	2010/07/07 19:02:50	1.80
@@ -122,6 +122,14 @@
 			}
 		}
 	} else if (arg_count(cmd, metadataignore_ARG)) {
+		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+		    yes_no_prompt("Setting metadataignore on %s will override "
+				  "preferred number of copies of VG %s "
+				  "metadata.\nAre you sure? [y/n]: ",
+				  pv_name, pv_vg_name(pv)) == 'n') {
+			log_error("Physical volume %s not changed", pv_name);
+			goto out;
+		}
 		if (!pv_change_metadataignore(pv, mda_ignore))
 			goto out;
 	} else {
--- LVM2/tools/vgextend.c	2010/07/07 18:59:46	1.56
+++ LVM2/tools/vgextend.c	2010/07/07 19:02:50	1.57
@@ -59,6 +59,16 @@
 	if (!archive(vg))
 		goto_bad;
 
+	if (arg_count(cmd, metadataignore_ARG) &&
+	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+	    yes_no_prompt("Setting metadataignore will override "
+			  "preferred number of copies of VG %s "
+			  "metadata.\nAre you sure? [y/n]: ",
+			  vg_name) == 'n') {
+		log_error("Volume group %s not changed", vg_name);
+		goto_bad;
+	}
+
 	/* extend vg */
 	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;


