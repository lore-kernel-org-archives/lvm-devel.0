From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 21:43:16 -0000
Subject: LVM2 man/vgsplit.8 tools/vgsplit.c test/t-vgsp ...
Message-ID: <20080111214316.24812.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 21:43:16

Modified files:
	man            : vgsplit.8 
	tools          : vgsplit.c 
Added files:
	test           : t-vgsplit-operation.sh 

Log message:
	Allow vgsplit into existing vg.
	Add vgsplit tests to validate operation for new and existing vg destinations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/man/vgsplit.8	2004/12/09 16:58:31	1.2
+++ LVM2/man/vgsplit.8	2008/01/11 21:43:16	1.3
@@ -10,20 +10,22 @@
 [\-M/\-\-metadatatype 1/2]
 [\-t/\-\-test] 
 [\-v/\-\-verbose] 
-ExistingVolumeGroupName NewVolumeGroupName
+SourceVolumeGroupName DestinationVolumeGroupName
 PhysicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
 .B vgsplit 
-creates 
-.I NewVolumeGroupName
-and moves
+moves
 .IR PhysicalVolumePath (s)
 from
-.I ExistingVolumeGroupName
-into it.
+.I SourceVolumeGroupName
+into
+.I DestinationVolumeGroupName\fP.
+If
+.I DestinationVolumeGroupName
+does not exist, it will be created.
 Logical Volumes cannot be split between Volume Groups.
-Each existing Logical Volumes must be entirely on the Physical Volumes forming
-either the old or the new Volume Group.
+Each existing Logical Volume must be entirely on the Physical Volumes forming
+either the source or the destination Volume Group.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH SEE ALSO
/cvs/lvm2/LVM2/test/t-vgsplit-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgsplit-operation.sh
+++ -	2008-01-11 21:43:16.646852000 +0000
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgsplit diagnostics'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  rm -f "$f1" "$f2" "$f3" "$f4"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgnames' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   vg1=$(this_test_)-test-vg1-$$          &&
+   vg2=$(this_test_)-test-vg2-$$          &&
+   pvcreate $d1 $d2 $d3 $d4'
+
+test_expect_success \
+  'vgsplit accepts new vg as destination of split' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts existing vg as destination of split' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/tools/vgsplit.c	2008/01/11 20:17:18	1.42
+++ LVM2/tools/vgsplit.c	2008/01/11 21:43:16	1.43
@@ -251,24 +251,24 @@
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
-		/* FIXME Remove this restriction */
-		log_error("Volume group \"%s\" already exists", vg_name_to);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
-	/* Set metadata format of original VG */
-	/* FIXME: need some common logic */
-	cmd->fmt = vg_from->fid->fmt;
-
-	/* Create new VG structure */
-	if (!(vg_to = vg_create(cmd, vg_name_to, vg_from->extent_size,
-				vg_from->max_pv, vg_from->max_lv,
-				vg_from->alloc, 0, NULL)))
-		goto error;
+		log_warn("Volume group \"%s\" already exists", vg_name_to);
+		/* FIXME: check compatibility with existing vg, esp attribs */
+	} else {
+
+		/* Set metadata format of original VG */
+		/* FIXME: need some common logic */
+		cmd->fmt = vg_from->fid->fmt;
+
+		/* Create new VG structure */
+		/* FIXME: allow user input same params as to vgcreate tool */
+		if (!(vg_to = vg_create(cmd, vg_name_to, vg_from->extent_size,
+					vg_from->max_pv, vg_from->max_lv,
+					vg_from->alloc, 0, NULL)))
+			goto error;
 
-	if (vg_from->status & CLUSTERED)
-		vg_to->status |= CLUSTERED;
+		if (vg_from->status & CLUSTERED)
+			vg_to->status |= CLUSTERED;
+	}
 
 	/* Archive vg_from before changing it */
 	if (!archive(vg_from))


