From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Nov 2008 15:29:25 -0000
Subject: LVM2/test t-listings.sh t-lvcreate-operation.s ...
Message-ID: <20081111152925.17132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-11 15:29:24

Added files:
	test           : t-listings.sh t-lvcreate-operation.sh 
	                 t-mirror-lvconvert-usage.sh 
	                 t-vgcfgbackup-usage.sh t-vgchange-usage.sh 

Log message:
	Import a bunch of new tests by jstava. Mostly everything pass, they however
	tend to expose the lvremove -ff vg ordering bug.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-listings.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-listings.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-listings.sh
+++ -	2008-11-11 15:29:25.263969000 +0000
@@ -0,0 +1,79 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests functionality of lvs, pvs, vgs, *display tools
+#
+
+. ./test-utils.sh
+
+get_lvs_()
+{
+  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+    *$2) true ;;
+    *) false ;;
+  esac
+}
+
+aux prepare_devs 5
+
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 0 $dev3
+pvcreate $dev4
+pvcreate --metadatacopies 0 $dev5
+
+#COMM bz195276 -- pvs doesn't show PVs until a VG is created
+pvs --noheadings|tee out
+test $(wc -l <out) -eq 5
+
+vgcreate -c n $vg $devs
+
+#COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
+pvs -o +pv_mda_count,pv_mda_free $devs
+for I in $dev2 $dev3 $dev5; do
+	aux check_pv_field_ $I pv_mda_count 0
+	aux check_pv_field_ $I pv_mda_free 0
+done
+vgs -o +vg_mda_count,vg_mda_free $vg
+aux check_vg_field_ $vg vg_mda_count 2
+
+#COMM pvs doesn't display --metadatacopies 0 PVs as orphans (bz409061)
+pvdisplay $dev2|grep "VG Name.*$vg"
+test $(pvs -o vg_name --noheadings $dev2) = $vg
+
+#COMM lvs displays snapshots (bz171215)
+lvcreate -l4 -n $lv1 $vg
+lvcreate -l4 -s -n $lv2 $vg/$lv1
+lvs $vg --noheadings|tee out
+test $(wc -l <out) -eq 2
+lvs -a --noheadings|tee out
+# should lvs -a display cow && real devices? (it doesn't)
+test $(wc -l <out) -eq 2
+dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+lvremove -f $vg/$lv2
+
+#COMM lvs -a displays mirror legs and log
+lvcreate -l4  -m2 -n$lv3 $vg
+lvs $vg --noheadings|tee out
+test $(wc -l <out) -eq 2
+lvs -a --noheadings|tee out
+test $(wc -l <out) -eq 6
+dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
+
+#COMM vgs with options from pvs still treats arguments as VGs (bz193543)
+vgs -o pv_name,vg_name $vg
+# would complain if not
+
+#COMM pvdisplay --maps feature (bz149814)
+pvdisplay $devs >out
+pvdisplay --maps $devs >out2
+not diff out out2
+
/cvs/lvm2/LVM2/test/t-lvcreate-operation.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-operation.sh
+++ -	2008-11-11 15:29:25.392211000 +0000
@@ -0,0 +1,33 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise some lvcreate diagnostics'
+
+. ./test-utils.sh
+
+cleanup_lvs() {
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+}
+
+aux prepare_pvs 2
+aux pvcreate --metadatacopies 0 $dev1
+aux vgcreate $vg $devs
+
+#COMM create snapshots of LVs on --metadatacopies 0 PV (bz450651)
+lvcreate -n$lv1 -l4 $vg $dev1
+lvcreate -n$lv2 -l4 -s $vg/$lv1
+#lvremove -f $vg/$lv2
+cleanup_lvs
+
/cvs/lvm2/LVM2/test/t-mirror-lvconvert-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-mirror-lvconvert-usage.sh
+++ -	2008-11-11 15:29:25.520187000 +0000
@@ -0,0 +1,95 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+dmsetup_has_dm_devdir_support_ || exit 200
+
+aux prepare_vg 5
+
+
+lv_is_on_() {
+	local lv=$1 #allready vg/lv
+	shift 1
+	lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
+	#is on all specified devs
+	for d in $*; do grep "$d(" out; done
+	#isn't on any other dev (we are set -e remember)
+	for d in $*; do ! grep -v "$d(" out; done
+	return 0
+}
+
+mimages_are_on_ ()
+{
+	local lv=$1
+	shift
+	local pvs="$*"
+	local mimages
+	local i
+
+	echo "Check if mirror images of $lv are on PVs $pvs"
+	rm -f out1 out2
+	echo $pvs | sed 's/ /\n/g' | sort | uniq > out1
+
+	mimages=$(lvs --noheadings -a -o lv_name $vg | grep "${lv}_mimage_" | \
+		sed 's/\[//g; s/\]//g')
+	for i in $mimages; do
+		echo "Checking $vg/$i"
+		lvs -a -odevices --noheadings $vg/$i | \
+			sed 's/([^)]*)//g; s/ //g; s/,/ /g' | sort | uniq >> out2
+	done
+
+	diff --ignore-blank-lines out1 out2
+}
+
+# ---------------------------------------------------------------------
+# Common environment setup/cleanup for each sub testcases
+
+prepare_lvs_()
+{
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+	:
+}
+
+check_and_cleanup_lvs_()
+{
+	lvs -a -o+devices $vg
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+}
+
+prepare_lvs_
+check_and_cleanup_lvs_
+
+
+#COMM "convert from 2-way mirror to linear -- specify leg to remove (bz453643)"
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvconvert -m0 $vg/$lv1 $dev2
+lv_is_on_ $vg/$lv1 $dev1
+check_and_cleanup_lvs_
+
+prepare_lvs_ 
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1 
+lvconvert -m-1 $vg/$lv1 $dev1
+lvs -a -o+devices 
+mimages_are_on_ $lv1 $dev2 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2
+lvs -a -o+devices 
+lv_is_on_ $vg/$lv1 $dev4 
+check_and_cleanup_lvs_
+
/cvs/lvm2/LVM2/test/t-vgcfgbackup-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgcfgbackup-usage.sh
+++ -	2008-11-11 15:29:25.635297000 +0000
@@ -0,0 +1,24 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+aux prepare_pvs 2
+
+# vgcfgbackup handles similar VG names (bz458941)
+vg1=${PREFIX}vg00
+vg1=${PREFIX}vg01
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcfgbackup -f /tmp/bak-%s >out
+grep "Volume group \"$vg1\" successfully backed up." out
+grep "Volume group \"$vg2\" successfully backed up." out
+
/cvs/lvm2/LVM2/test/t-vgchange-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgchange-usage.sh
+++ -	2008-11-11 15:29:25.759506000 +0000
@@ -0,0 +1,51 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgchange diagnostics'
+
+. ./test-utils.sh
+
+aux prepare_pvs 3
+pvcreate --metadatacopies 0 $dev1
+vgcreate $vg $devs
+
+get_vg_field() {
+	local vg=$1
+	local field=$2
+	local value
+	vgs --noheading -o $field $vg | sed 's/^ *//'
+}
+
+vgdisplay $vg
+
+# vgchange -p MaxPhysicalVolumes (bz202232)
+aux check_vg_field_ $vg max_pv 0
+vgchange -p 128 $vg
+aux check_vg_field_ $vg max_pv 128
+
+pv_count=$(get_vg_field $vg pv_count)
+not vgchange -p 2 $vg 2>err
+grep "MaxPhysicalVolumes is less than the current number $pv_count of PVs for" err
+aux check_vg_field_ $vg max_pv 128
+
+# vgchange -l MaxLogicalVolumes
+aux check_vg_field_ $vg max_lv 0
+vgchange -l 128 $vg
+aux check_vg_field_ $vg max_lv 128
+
+lvcreate -l4 -n$lv1 $vg
+lvcreate -l4 -n$lv2 $vg
+
+lv_count=$(get_vg_field $vg lv_count)
+not vgchange -l 1 $vg 2>err
+grep "MaxLogicalVolume is less than the current number $lv_count of LVs for"  err
+aux check_vg_field_ $vg max_lv 128
+


