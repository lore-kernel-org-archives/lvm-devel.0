From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 21 Aug 2010 15:43:46 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100821154346.11816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-21 15:43:45

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Verify that pvcreate --dataalignment really does override the topology
	detected alignment.
	
	NOTE: lvm2 doesn't detect MD 1.2 metadata (now the default on RHEL6) so
	for now I'm forcing 1.0 metadata.  This was needed to be able to reuse
	the existing loop devices but recreate the md device with different
	raid0 striping.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/t-pvcreate-operation-md.sh	2010/08/12 04:56:05	1.9
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/08/21 15:43:45	1.10
@@ -41,13 +41,17 @@
 	sleep 2
 	rm -f $mddev
     fi
+}
+
+cleanup_md_and_teardown() {
+    cleanup_md
     teardown
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)
 test -b "$mddev" && exit 200
-mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
-trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
+mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
+trap 'aux cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
 test -b "$mddev" || exit 200
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
@@ -113,3 +117,27 @@
 	pvremove $mddev_p
     fi
 fi
+
+# Test newer topology-aware alignment detection w/ --dataalignment override
+if [ $linux_minor -ge 33 ]; then
+    cleanup_md
+    pvcreate -f $dev1
+    pvcreate -f $dev2
+
+    # create 2 disk MD raid0 array (stripe_width=2M)
+    test -b "$mddev" && exit 200
+    mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 1024 $dev1 $dev2
+    test -b "$mddev" || exit 200
+
+    # optimal_io_size=2097152, minimum_io_size=1048576
+    pv_align="2.00m"
+    pvcreate --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check_pv_field_ $mddev pe_start $pv_align
+
+    # now verify pe_start alignment override using --dataalignment
+    pv_align="192.00k"
+    pvcreate --dataalignment 64k --metadatasize 128k \
+	--config 'devices { md_chunk_alignment=0 }' $mddev
+    check_pv_field_ $mddev pe_start $pv_align
+fi


