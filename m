From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:39:40 -0000
Subject: LVM2 test/t-vgcreate-usage.sh tools/lvmcmdline.c
Message-ID: <20100628203940.20665.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:39:39

Modified files:
	test           : t-vgcreate-usage.sh 
	tools          : lvmcmdline.c 

Log message:
	Ensure --metadatacopies parameter gets interpreted based on command.
	
	Now that we have both --pvmetadatacopies and --vgmetadatacopies,
	we need to make sure --metadatacopies gets interpreted correctly.
	
	For pv commands, --metadatacopies should imply --pvmetadatacopies,
	and for vg commands, --vgmetadatacopies.
	
	Note: this will change the behavior of vgcreate with --metadatacopies
	to be a synonym for --vgmetadatacopies.  Previously, --metadatacopies
	would apply to any PVs given with vgcreate that needed an implicit
	pvcreate.  As a result, one small change is needed to one of the nightly
	tests - t-vgcreate-usage.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/test/t-vgcreate-usage.sh	2010/05/12 10:08:36	1.15
+++ LVM2/test/t-vgcreate-usage.sh	2010/06/28 20:39:39	1.16
@@ -115,7 +115,7 @@
     vgremove -f $vg
     pvremove -f $dev1
 done
-not vgcreate -c n --metadatacopies 0 $vg $dev1
+not vgcreate -c n --pvmetadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
 vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
 check_pv_field_ $dev1 pv_mda_count 0
--- LVM2/tools/lvmcmdline.c	2010/05/06 11:15:56	1.122
+++ LVM2/tools/lvmcmdline.c	2010/06/28 20:39:39	1.123
@@ -827,8 +827,13 @@
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
-	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
-	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG))
+	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG))
+		return EINVALID_CMD_LINE;
+
+	if ((!strncmp(cmd->command->name, "pv", 2) &&
+	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG)) ||
+	    (!strncmp(cmd->command->name, "vg", 2) &&
+	     !_merge_synonym(cmd, metadatacopies_ARG, vgmetadatacopies_ARG)))
 		return EINVALID_CMD_LINE;
 
 	/* Zero indicates success */


