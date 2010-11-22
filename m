From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Nov 2010 14:26:12 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20101122142612.7823.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-22 14:25:22

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.260&r2=1.261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1798&r2=1.1799
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.424&r2=1.425

--- LVM2/VERSION	2010/11/09 02:58:06	1.260
+++ LVM2/VERSION	2010/11/22 14:25:22	1.261
@@ -1 +1 @@
-2.02.77(2)-cvs (2010-11-08)
+2.02.77(2)-cvs (2010-11-22)
--- LVM2/VERSION_DM	2010/11/09 02:58:06	1.69
+++ LVM2/VERSION_DM	2010/11/22 14:25:22	1.70
@@ -1 +1 @@
-1.02.58-cvs (2010-11-08)
+1.02.58-cvs (2010-11-22)
--- LVM2/WHATS_NEW	2010/11/17 10:19:29	1.1798
+++ LVM2/WHATS_NEW	2010/11/22 14:25:22	1.1799
@@ -1,10 +1,13 @@
-Version 2.02.77 -
-===================================
+Version 2.02.77 - 22nd November 2010
+====================================
+  Allocate a pool for dummy VG in _pvsegs_sub_single.
+  Add PV and LV segment types and functions to liblvm.
+  Add set_property functions to liblvm.
   Remove tag length restriction and allow / = ! : # & characters.
   Support repetition of --addtag and --deltag arguments.
   Add infrastructure for specific cmdline arguments to be repeated in groups.
   Split the_args cmdline arguments and values into arg_props and arg_values.
-  Fix fsadm to not require '-f' for resize of unmounted filesystem.
+  Fix fsadm no longer to require '-f' to resize an unmounted filesystem.
   Fix fsadm to detect mounted filesystems on older systems. (2.0.75)
   Extend cling allocation policy to recognise PV tags (cling_by_tags).
   Add allocation/cling_tag_list to lvm.conf.
--- LVM2/WHATS_NEW_DM	2010/11/19 13:17:27	1.424
+++ LVM2/WHATS_NEW_DM	2010/11/22 14:25:22	1.425
@@ -1,5 +1,5 @@
-Version 1.02.58 - 
-===================================
+Version 1.02.58 - 22nd November 2010
+====================================
   Fix _output_field crash from field_id free with DEBUG_MEM. (1.02.57)
 
 Version 1.02.57 - 8th November 2010


