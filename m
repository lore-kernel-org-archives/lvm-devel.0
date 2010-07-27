From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jul 2010 20:05:30 -0000
Subject: LVM2 tools/vgck.c test/t-activate-missing.sh . ...
Message-ID: <20100727200530.12111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-07-27 20:05:30

Modified files:
	tools          : vgck.c 
	test           : t-activate-missing.sh 
	.              : WHATS_NEW 
Added files:
	test           : t-nomda-missing.sh 

Log message:
	Make vgck warn about missing PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-nomda-missing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-missing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1670&r2=1.1671

--- LVM2/tools/vgck.c	2010/07/09 15:34:48	1.26
+++ LVM2/tools/vgck.c	2010/07/27 20:05:29	1.27
@@ -31,6 +31,12 @@
 		return ECMD_FAILED;
 	}
 
+	if (vg_missing_pv_count(vg)) {
+		log_error("The volume group is missing %d physical volumes.",
+			  vg_missing_pv_count(vg));
+		return ECMD_FAILED;
+	}
+
 	return ECMD_PROCESSED;
 }
 
/cvs/lvm2/LVM2/test/t-nomda-missing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-nomda-missing.sh
+++ -	2010-07-27 20:05:30.660682000 +0000
@@ -0,0 +1,73 @@
+#!/bin/bash
+
+. ./test-utils.sh
+
+prepare_devs 4
+pvcreate $dev1 $dev2
+pvcreate --metadatacopies 0 $dev3 $dev4
+vgcreate $vg $dev1 $dev2 $dev3 $dev4
+
+lvcreate -l1 -n linear1 $vg $dev1
+lvcreate -l1 -n linear2 $vg $dev2
+lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+
+lvcreate -l1 -n origin1 $vg $dev1
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
+lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+
+vgchange -a n $vg
+disable_dev $dev1
+not vgchange -a y $vg
+not vgck $vg
+
+check inactive $vg linear1
+check active $vg linear2
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg linear12
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+enable_dev $dev1
+disable_dev $dev2
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg linear1
+check inactive $vg linear2
+check inactive $vg linear12
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+enable_dev $dev2
+disable_dev $dev3
+not vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check inactive $vg mirror123
+check active $vg mirror12
+
+vgchange -a n $vg
+enable_dev $dev3
+disable_dev $dev4
+vgchange -a y $vg
+not vgck $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check active $vg mirror12
+check active $vg mirror123
--- LVM2/test/t-activate-missing.sh	2010/05/12 06:02:28	1.1
+++ LVM2/test/t-activate-missing.sh	2010/07/27 20:05:29	1.2
@@ -24,6 +24,7 @@
 vgchange -a n $vg
 disable_dev $dev1
 not vgchange -a y $vg
+not vgck $vg
 
 check inactive $vg linear1
 check active $vg linear2
@@ -37,6 +38,7 @@
 enable_dev $dev1
 disable_dev $dev2
 not vgchange -a y $vg
+not vgck $vg
 
 check active $vg linear1
 check inactive $vg linear2
@@ -50,6 +52,7 @@
 enable_dev $dev2
 disable_dev $dev3
 not vgchange -a y $vg
+not vgck $vg
 
 check active $vg origin1
 check active $vg s_napshot2
@@ -63,6 +66,7 @@
 enable_dev $dev3
 disable_dev $dev4
 vgchange -a y $vg
+not vgck $vg
 
 check active $vg origin1
 check active $vg s_napshot2
--- LVM2/WHATS_NEW	2010/07/21 19:44:25	1.1670
+++ LVM2/WHATS_NEW	2010/07/27 20:05:30	1.1671
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Make vgck warn about missing PVs.
   Clarify help text for vg_mda_count.
   Check if cluster log daemon is running before allowing cmirror create.
   Check if LV with specified name already exists when splitting a mirror.


