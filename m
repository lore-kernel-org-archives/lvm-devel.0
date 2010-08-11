From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 11 Aug 2010 17:43:12 -0400
Subject: [PATCH v5 2/2] change default alignment of pe_start to 1MB
In-Reply-To: <20100811212538.GC8422@redhat.com>
References: <1281479088-1553-1-git-send-email-snitzer@redhat.com>
	<1281479088-1553-2-git-send-email-snitzer@redhat.com>
	<20100811212538.GC8422@redhat.com>
Message-ID: <20100811214311.GD8422@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The new standard in the storage industry is to default alignment of data
areas to 1MB.  fdisk, parted, and mdadm have all been updated to this 
default.

Update LVM to align the PV's data area start (pe_start) to 1MB.  This
provides a more useful default than the previous default of 64K (which
generally ended up being a 192K pe_start once the first metadata area
was created).

Before this patch:
# pvs -o name,vg_mda_size,pe_start                                                                                                                                     
  PV         VMdaSize  1st PE
  /dev/sdd     188.00k 192.00k

After this patch:
# pvs -o name,vg_mda_size,pe_start                                                                                                                                     
  PV         VMdaSize  1st PE
  /dev/sdd    1020.00k   1.00m

The heuristic for setting the default alignment for LVM data areas is:
- If the default value (1MB) is a multiple of the detected alignment
  then just use the default.
- Otherwise, use the detected value.

In practice this means we'll almost always use 1MB -- that is unless:
- the alignment was explicitly specified with --dataalignment
- or MD's full stripe width, or the {minimum,optimal}_io_size exceeds
  1MB
- or the specified/detected value is not a power-of-2

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
--
 doc/example.conf.in             |    2 +-
 lib/config/defaults.h           |    2 ++
 lib/metadata/metadata.c         |   33 +++++++++++++++++++++------------
 test/lvm-utils.sh               |    3 ++-
 test/t-covercmd.sh              |    2 +-
 test/t-pvcreate-operation-md.sh |   23 +++++++++--------------
 test/t-pvcreate-usage.sh        |    6 +++---
 test/t-topology-support.sh      |    2 +-
 test/t-vgcreate-usage.sh        |    6 +++---
 test/t-vgextend-usage.sh        |    6 +++---
 test/t-vgsplit-operation.sh     |    2 +-
 test/test-utils.sh              |    2 +-
 12 files changed, 48 insertions(+), 41 deletions(-)

Index: lvm2/doc/example.conf.in
===================================================================
--- lvm2.orig/doc/example.conf.in
+++ lvm2/doc/example.conf.in
@@ -113,7 +113,7 @@ devices {
     # Alignment (in KB) of start of data area when creating a new PV.
     # If a PV is placed directly upon an md device and md_chunk_alignment or
     # data_alignment_detection is enabled this parameter is ignored.
-    # Set to 0 for the default alignment of 64KB or page size, if larger.
+    # Set to 0 for the default alignment of 1MB or page size, if larger.
     data_alignment = 0
 
     # By default, the start of the PV's aligned data area will be shifted by
Index: lvm2/lib/metadata/metadata.c
===================================================================
--- lvm2.orig/lib/metadata/metadata.c
+++ lvm2/lib/metadata/metadata.c
@@ -62,15 +62,23 @@ static uint32_t _vg_bad_status_bits(cons
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
+static int _alignment_overrides_default(unsigned long data_alignment)
+{
+	return data_alignment && (DEFAULT_PE_ALIGN % data_alignment);
+}
+
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
+	unsigned long temp_pe_align;
+
 	if (pv->pe_align)
 		goto out;
 
 	if (data_alignment)
 		pv->pe_align = data_alignment;
 	else
-		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+		pv->pe_align = MAX((DEFAULT_PE_ALIGN << SECTOR_SHIFT),
+				   lvm_getpagesize()) >> SECTOR_SHIFT;
 
 	if (!pv->dev)
 		goto out;
@@ -79,10 +87,11 @@ unsigned long set_pe_align(struct physic
 	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
-				  DEFAULT_MD_CHUNK_ALIGNMENT))
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_md_stripe_width(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
+				  DEFAULT_MD_CHUNK_ALIGNMENT)) {
+		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
+		if (_alignment_overrides_default(temp_pe_align))
+			pv->pe_align = temp_pe_align;
+	}
 
 	/*
 	 * Align to topology's minimum_io_size or optimal_io_size if present
@@ -94,13 +103,13 @@ unsigned long set_pe_align(struct physic
 	if (find_config_tree_bool(pv->fmt->cmd,
 				  "devices/data_alignment_detection",
 				  DEFAULT_DATA_ALIGNMENT_DETECTION)) {
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_minimum_io_size(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
-
-		pv->pe_align = MAX(pv->pe_align,
-				   dev_optimal_io_size(pv->fmt->cmd->sysfs_dir,
-						       pv->dev));
+		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
+		if (_alignment_overrides_default(temp_pe_align))
+			pv->pe_align = temp_pe_align;
+
+		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
+		if (_alignment_overrides_default(temp_pe_align))
+			pv->pe_align = temp_pe_align;
 	}
 
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
Index: lvm2/test/lvm-utils.sh
===================================================================
--- lvm2.orig/test/lvm-utils.sh
+++ lvm2/test/lvm-utils.sh
@@ -103,9 +103,10 @@ check_pv_field_()
     local pv=$1;
     local field=$2;
     local expected=$3;
+    local pvs_args=$4; # optional
     local actual;
 
-    actual=$(trim $(pvs --noheadings -o $field $pv))
+    actual=$(trim $(pvs --noheadings $pvs_args -o $field $pv))
 if test "$verbose" = "t"
 then
   echo "check_pv_field_ PV=$pv, field=$field, actual=$actual, expected=$expected"
Index: lvm2/test/t-pvcreate-operation-md.sh
===================================================================
--- lvm2.orig/test/t-pvcreate-operation-md.sh
+++ lvm2/test/t-pvcreate-operation-md.sh
@@ -52,14 +52,14 @@ test -b "$mddev" || exit 200
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
-pv_align="192.00k"
+pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
 check_pv_field_ $mddev pe_start $pv_align
 
 # Test md_chunk_alignment independent of topology-aware detection
-pv_align="256.00k"
+pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
@@ -71,7 +71,8 @@ linux_minor=$(echo `uname -r` | cut -d'.
 # Test newer topology-aware alignment detection
 # - first added to 2.6.31 but not "reliable" until 2.6.33
 if [ $linux_minor -ge 33 ]; then
-    pv_align="256.00k"
+    pv_align="1.00m"
+    # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
     check_pv_field_ $mddev pe_start $pv_align
@@ -103,15 +104,9 @@ EOF
 	alignment_offset=`cat $sysfs_alignment_offset` || \
 	alignment_offset=0
 
-    if [ "$alignment_offset" = "512" ]; then
-	pv_align="256.50k"
-	pvcreate --metadatasize 128k $mddev_p
-	check_pv_field_ $mddev_p pe_start $pv_align
-	pvremove $mddev_p
-    elif [ "$alignment_offset" = "2048" ]; then
-	pv_align="258.00k"
-	pvcreate --metadatasize 128k $mddev_p
-	check_pv_field_ $mddev_p pe_start $pv_align
-	pvremove $mddev_p
-    fi
+    # default alignment is 1M, add alignment_offset
+    pv_align=$((1048576+$alignment_offset))B
+    pvcreate --metadatasize 128k $mddev_p
+    check_pv_field_ $mddev_p pe_start $pv_align "--units b"
+    pvremove $mddev_p
 fi
Index: lvm2/test/t-pvcreate-usage.sh
===================================================================
--- lvm2.orig/test/t-pvcreate-usage.sh
+++ lvm2/test/t-pvcreate-usage.sh
@@ -119,11 +119,11 @@ check_pv_field_ $dev1 pe_start $pv_align
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
 check_pv_field_ $dev1 pe_start $pv_align
 
-# data area is aligned to 64k by default,
+# data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="195.50k"
+pv_align="1052160B" # 1048576 + (7*512)
 pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
-check_pv_field_ $dev1 pe_start $pv_align
+check_pv_field_ $dev1 pe_start $pv_align "--units b"
 
 # 2nd metadata area is created without problems when
 # data area start is shifted by the specified alignment_offset
Index: lvm2/test/t-topology-support.sh
===================================================================
--- lvm2.orig/test/t-topology-support.sh
+++ lvm2/test/t-topology-support.sh
@@ -57,7 +57,7 @@ test_snapshot_mount()
 # FIXME add more topology-specific tests and validation (striped LVs, etc)
 
 NUM_DEVS=1
-PER_DEV_SIZE=33
+PER_DEV_SIZE=34
 DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
 
 # ---------------------------------------------
Index: lvm2/test/t-vgcreate-usage.sh
===================================================================
--- lvm2.orig/test/t-vgcreate-usage.sh
+++ lvm2/test/t-vgcreate-usage.sh
@@ -130,11 +130,11 @@ check_pv_field_ $dev1 pe_start 200.00k
 vgremove -f $vg
 pvremove -f $dev1
 
-# data area is aligned to 64k by default,
+# data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="195.50k"
+pv_align="1052160B" # 1048576 + (7*512)
 vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check_pv_field_ $dev1 pe_start $pv_align
+check_pv_field_ $dev1 pe_start $pv_align "--units b"
 vgremove -f $vg
 pvremove -f $dev1
 
Index: lvm2/test/t-vgextend-usage.sh
===================================================================
--- lvm2.orig/test/t-vgextend-usage.sh
+++ lvm2/test/t-vgextend-usage.sh
@@ -67,11 +67,11 @@ check_pv_field_ $dev1 pe_start 200.00k
 vgreduce $vg $dev1
 pvremove -f $dev1
 
-# data area is aligned to 64k by default,
+# data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="195.50k"
+pv_align="1052160B" # 1048576 + (7*512)
 vgextend --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check_pv_field_ $dev1 pe_start $pv_align
+check_pv_field_ $dev1 pe_start $pv_align "--units b"
 vgremove -f $vg
 pvremove -f $dev1
 
Index: lvm2/test/t-vgsplit-operation.sh
===================================================================
--- lvm2.orig/test/t-vgsplit-operation.sh
+++ lvm2/test/t-vgsplit-operation.sh
@@ -17,7 +17,7 @@ COMM() {  
 	LAST_TEST="$@"
 }
 
-prepare_pvs 5 257
+prepare_pvs 5 258
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata
Index: lvm2/test/test-utils.sh
===================================================================
--- lvm2.orig/test/test-utils.sh
+++ lvm2/test/test-utils.sh
@@ -264,7 +264,7 @@ prepare_devs() {
 	local n="$1"
 	test -z "$n" && n=3
 	local devsize="$2"
-	test -z "$devsize" && devsize=33
+	test -z "$devsize" && devsize=34
 	local pvname="$3"
 	test -z "$pvname" && pvname="pv"
 
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_DEFAULTS_H
 #define _LVM_DEFAULTS_H
 
+#define DEFAULT_PE_ALIGN 2048
+
 #define DEFAULT_ARCHIVE_ENABLED 1
 #define DEFAULT_BACKUP_ENABLED 1
 
Index: lvm2/test/t-covercmd.sh
===================================================================
--- lvm2.orig/test/t-covercmd.sh
+++ lvm2/test/t-covercmd.sh
@@ -30,7 +30,7 @@ pvcreate $dev1
 pvcreate --metadatacopies 0 $dev2
 pvcreate --metadatacopies 0 $dev3
 pvcreate $dev4
-pvcreate -u $TEST_UUID --metadatacopies 0 $dev5
+pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
 vgcreate -c n $vg $devs
 lvcreate -n $lv -l 5 -i5 -I256 $vg
 


