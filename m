From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2010 19:15:01 -0000
Subject: LVM2 man/pvchange.8.in man/vgextend.8.in test/ ...
Message-ID: <20100707191501.31957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-07 19:14:59

Modified files:
	man            : pvchange.8.in vgextend.8.in 
	test           : t-metadata-balance.sh 
	tools          : commands.h pvchange.c vgextend.c 

Log message:
	Add --force to pvchange, and allow override of prompt involving metadataignore.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-balance.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/man/pvchange.8.in	2010/07/02 17:05:22	1.4
+++ LVM2/man/pvchange.8.in	2010/07/07 19:14:57	1.5
@@ -5,6 +5,7 @@
 .B pvchange
 [\-\-addtag Tag]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
+[\-f|\-\-force]
 [\-\-deltag Tag]
 [\-\-metadataignore y|n]
 [\-h|\-?|\-\-help]
--- LVM2/man/vgextend.8.in	2010/06/30 13:03:48	1.7
+++ LVM2/man/vgextend.8.in	2010/07/07 19:14:57	1.8
@@ -4,6 +4,7 @@
 .SH SYNOPSIS
 .B vgextend
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-f|\-\-force]
 [\-t|\-\-test]
 [\-v|\-\-verbose]
 [ \fIPHYSICAL DEVICE OPTIONS\fP ]
--- LVM2/test/t-metadata-balance.sh	2010/06/30 22:22:00	1.3
+++ LVM2/test/t-metadata-balance.sh	2010/07/07 19:14:58	1.4
@@ -214,7 +214,7 @@
 	vgextend $vg1 $dev3
 	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 1))
 	echo Using pvchange to unignore should update vg_mda_used_count
-	pvchange --metadataignore n $dev3
+	pvchange -f --metadataignore n $dev3
 	check_pv_field_ $dev3 pv_mda_used_count $mdacp
 	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 2))
 	echo Set unmanaged on the vg should keep ignore bits the same during vgextend
@@ -225,7 +225,7 @@
 	check_pv_field_ $dev4 pv_mda_used_count $mdacp
 	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 3))
 	echo Using pvchange to ignore should update vg_mda_used_count
-	pvchange --metadataignore y $dev4
+	pvchange -f --metadataignore y $dev4
 	check_pv_field_ $dev4 pv_mda_used_count 0
 	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 2))
 	vgremove -f $vg1
--- LVM2/tools/commands.h	2010/06/30 13:03:48	1.152
+++ LVM2/tools/commands.h	2010/07/07 19:14:58	1.153
@@ -451,6 +451,7 @@
    "\t[-a|--all]\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
@@ -463,7 +464,7 @@
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, metadataignore_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, force_ARG, metadataignore_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
@@ -846,6 +847,7 @@
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
--- LVM2/tools/pvchange.c	2010/07/07 19:02:50	1.80
+++ LVM2/tools/pvchange.c	2010/07/07 19:14:58	1.81
@@ -123,6 +123,7 @@
 		}
 	} else if (arg_count(cmd, metadataignore_ARG)) {
 		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+		    (arg_count(cmd, force_ARG) == PROMPT) &&
 		    yes_no_prompt("Setting metadataignore on %s will override "
 				  "preferred number of copies of VG %s "
 				  "metadata.\nAre you sure? [y/n]: ",
--- LVM2/tools/vgextend.c	2010/07/07 19:02:50	1.57
+++ LVM2/tools/vgextend.c	2010/07/07 19:14:58	1.58
@@ -61,6 +61,7 @@
 
 	if (arg_count(cmd, metadataignore_ARG) &&
 	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+	    (pp.force == PROMPT) &&
 	    yes_no_prompt("Setting metadataignore will override "
 			  "preferred number of copies of VG %s "
 			  "metadata.\nAre you sure? [y/n]: ",


