From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Aug 2010 04:56:06 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100812045606.21980.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-12 04:56:06

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	fix t-pvcreate-operation-md.sh to require kernel.org Linux >= 2.6.33 for
	the final alignment_offset check.  In the future, might look to check
	for the RHEL6 kernel too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-pvcreate-operation-md.sh	2010/08/12 04:11:49	1.8
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/08/12 04:56:05	1.9
@@ -99,14 +99,17 @@
     mddev_p=/dev/${base_mddev_p}
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
+    # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
     sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
     [ -f $sysfs_alignment_offset -a $linux_minor -ge 33 ] && \
 	alignment_offset=`cat $sysfs_alignment_offset` || \
 	alignment_offset=0
 
-    # default alignment is 1M, add alignment_offset
-    pv_align=$((1048576+$alignment_offset))B
-    pvcreate --metadatasize 128k $mddev_p
-    check_pv_field_ $mddev_p pe_start $pv_align "--units b"
-    pvremove $mddev_p
+    if [ $alignment_offset -gt 0 ]; then    
+        # default alignment is 1M, add alignment_offset
+	pv_align=$((1048576+$alignment_offset))B
+	pvcreate --metadatasize 128k $mddev_p
+	check_pv_field_ $mddev_p pe_start $pv_align "--units b"
+	pvremove $mddev_p
+    fi
 fi


