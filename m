From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Nov 2008 19:02:47 -0000
Subject: LVM2 ./WHATS_NEW tools/vgdisplay.c
Message-ID: <20081107190247.11990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-11-07 19:02:47

Modified files:
	.              : WHATS_NEW 
	tools          : vgdisplay.c 

Log message:
	Fix vgdisplay return code and exit status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.990&r2=1.991
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2008/11/03 18:59:58	1.990
+++ LVM2/WHATS_NEW	2008/11/07 19:02:47	1.991
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Fix vgdisplay return code and exit status.
   Move list.c into libdevmapper and rename functions.
   Rename a couple of variables that matched function names.
   Use simplified x.y.z version number in libdevmapper.pc.
--- LVM2/tools/vgdisplay.c	2008/06/10 20:07:04	1.21
+++ LVM2/tools/vgdisplay.c	2008/11/07 19:02:47	1.22
@@ -98,8 +98,8 @@
 	}
 **********/
 
-	process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
-			vgdisplay_single);
+	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
 	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ?
@@ -112,6 +112,4 @@
 		return LVM_E_NO_VG;
 	}
 ************/
-
-	return ECMD_PROCESSED;
 }


