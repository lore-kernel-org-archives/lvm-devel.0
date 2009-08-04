From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 4 Aug 2009 16:02:39 -0000
Subject: LVM2/test t-pvcreate-usage.sh t-pvcreate-opera ...
Message-ID: <20090804160239.24370.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-08-04 16:02:39

Modified files:
	test           : t-pvcreate-usage.sh 
Added files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Added basic pvcreate --dataalignmentoffset testing to t-pvcreate-usage.sh
	Added topology testing via new test/t-pvcreate-operation-md.sh
	- requires mdadm and rawhide kernel for full test coverage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

/cvs/lvm2/LVM2/test/t-pvcreate-operation-md.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pvcreate-operation-md.sh
+++ -	2009-08-04 16:02:39.741117000 +0000
@@ -0,0 +1,112 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# skip this test if mdadm or sfdisk (or others) aren't available
+which mdadm || exit 200
+which sfdisk || exit 200
+which perl || exit 200
+which awk || exit 200
+which cut || exit 200
+
+. ./test-utils.sh
+
+prepare_lvmconf '[ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux prepare_devs 2
+
+# Have MD use a non-standard name to avoid colliding with an existing MD device
+# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
+# - newer mdadm _completely_ defers to udev to create the associated device node
+mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
+[ $mdadm_maj -ge 3 ] && \
+    mddev=/dev/md/md_lvm_test0 || \
+    mddev=/dev/md_lvm_test0
+
+cleanup_md() {
+    # sleeps offer hack to defeat: 'md: md127 still in use'
+    # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
+    sleep 2
+    mdadm --stop $mddev
+    if [ -b "$mddev" ]; then
+        # mdadm doesn't always cleanup the device node
+	sleep 2
+	rm -f $mddev
+    fi
+    teardown_
+}
+
+# create 2 disk MD raid0 array (stripe_width=128K)
+[ -b "$mddev" ] && exit 200
+mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
+trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
+
+# Test alignment of PV on MD without any MD-aware or topology-aware detection
+# - should treat $mddev just like any other block device
+pv_align="192.00K"
+pvcreate --metadatasize 128k \
+    --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check_pv_field_ $mddev pe_start $pv_align
+
+# Test md_chunk_alignment independent of topology-aware detection
+pv_align="256.00K"
+pvcreate --metadatasize 128k \
+    --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check_pv_field_ $mddev pe_start $pv_align
+
+# Get linux minor version
+linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
+
+# Test newer topology-aware alignment detection
+if [ $linux_minor -gt 31 ]; then
+    pv_align="256.00K"
+    pvcreate --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check_pv_field_ $mddev pe_start $pv_align
+fi
+
+# partition MD array directly, depends on blkext in Linux >= 2.6.28
+if [ $linux_minor -gt 27 ]; then
+    # create one partition
+    sfdisk $mddev <<EOF
+,,83
+EOF
+    # make sure partition on MD is _not_ removed
+    # - tests partition -> parent lookup via sysfs paths
+    not pvcreate --metadatasize 128k $mddev
+
+    # verify alignment_offset is accounted for in pe_start
+    # - topology infrastructure is available in Linux >= 2.6.31
+    # - also tests partition -> parent lookup via sysfs paths
+
+    # Oh joy: need to lookup /sys/block/md127 rather than /sys/block/md_lvm_test0
+    mddev_maj_min=$(ls -lL $mddev | awk '{ print $5 $6 }' | perl -pi -e 's|,|:|')
+    mddev_p_sysfs_name=$(echo /sys/dev/block/${mddev_maj_min}/*p1)
+    base_mddev_p=`basename $mddev_p_sysfs_name`
+    mddev_p=/dev/${base_mddev_p}
+
+    # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
+    sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
+    [ -f $sysfs_alignment_offset ] && \
+	alignment_offset=`cat $sysfs_alignment_offset` || \
+	alignment_offset=0
+
+    if [ "$alignment_offset" = "512" ]; then
+	pv_align="256.50K"
+	pvcreate --metadatasize 128k $mddev_p
+	check_pv_field_ $mddev_p pe_start $pv_align
+	pvremove $mddev_p
+    elif [ "$alignment_offset" = "2048" ]; then
+	pv_align="258.00K"
+	pvcreate --metadatasize 128k $mddev_p
+	check_pv_field_ $mddev_p pe_start $pv_align
+	pvremove $mddev_p
+    fi
+fi
--- LVM2/test/t-pvcreate-usage.sh	2009/06/06 16:40:39	1.11
+++ LVM2/test/t-pvcreate-usage.sh	2009/08/04 16:02:39	1.12
@@ -116,6 +116,18 @@
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
 check_pv_field_ $dev1 pe_start $pv_align
 
+# data area is aligned to 64k by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="195.50K"
+pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
+check_pv_field_ $dev1 pe_start $pv_align
+
+# 2nd metadata area is created without problems when
+# data area start is shifted by the specified alignment_offset
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s $dev1
+check_pv_field_ $dev1 pv_mda_count 2
+# FIXME: compare start of 2nd mda with and without --dataalignmentoffset
+
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
 pvcreate --dataalignment 256k $dev1


