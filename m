From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:13 +0000 (GMT)
Subject: main - man: space after size
Message-ID: <20220710232213.D77113857023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe6fb1ec521407ec586ebda66d67345e33cfc39e
Commit:        fe6fb1ec521407ec586ebda66d67345e33cfc39e
Parent:        d2667bc25bccaf0f70cc2ded0fd3f25a79cb4f6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 15:10:58 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

man: space after size

Put space between size and SI unit.
Automatically make this 'space' as fixed size by Makefile sed script.
---
 man/Makefile.in        |  1 +
 man/dmstats.8_main     |  4 ++--
 man/lvconvert.8_pregen | 12 ++++++------
 man/lvcreate.8_end     | 24 ++++++++++++------------
 man/lvcreate.8_pregen  | 12 ++++++------
 man/lvmcache.7_main    |  6 +++---
 man/pvcreate.8_end     |  6 +++---
 man/vgchange.8_pregen  |  2 +-
 man/vgcreate.8_pregen  |  2 +-
 tools/args.h           | 18 +++++++++---------
 10 files changed, 44 insertions(+), 43 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index d3f0f583a..8488d309f 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -202,6 +202,7 @@ $(SED) -i -e "/^.TH/ !s+-+\\\-+g" \
 	  -e "s+machine-id+machine\\\-id+g" \
 	  -e "s+lvm-full+lvm\\\-full+g" \
 	  -e "s+lvm-lvpoll+lvm\\\-lvpoll+g" \
+	  -e "s+\([[:digit:]]\)\s\([KMGTPE]iB\)+\1\\\ \2+g" \
 	  $@
 endef
 
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index bf492c554..4f9a9fc7f 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -1142,7 +1142,7 @@ Delete all regions on all devices
 #
 .B dmstats delete --alldevices --allregions
 .P
-Create a whole-device region with areas 10GiB in size on vg00/lvol1
+Create a whole-device region with areas 10 GiB in size on vg00/lvol1
 using dmsetup
 .br
 .br
@@ -1151,7 +1151,7 @@ using dmsetup
 .br
 vg00-lvol1: Created new region with 5 area(s) as region ID 1
 .P
-Create a 1GiB region with 16 areas at the start of vg00/lvol1
+Create a 1 GiB region with 16 areas at the start of vg00/lvol1
 .br
 #
 .B dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 22de7467f..1e5582bf9 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1091,14 +1091,14 @@ The name of a cache volume.
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
-For snapshots, the value must be a power of 2 between 4KiB and 512KiB
+For snapshots, the value must be a power of 2 between 4 KiB and 512 KiB
 and the default value is 4.
-For a cache pool the value must be between 32KiB and 1GiB
+For a cache pool the value must be between 32 KiB and 1 GiB
 and the default value is 64.
-For a thin pool the value must be between 64KiB and 1GiB
+For a thin pool the value must be between 64 KiB and 1 GiB
 and the default value starts with 64 and scales up to fit the
-pool metadata size within 128MiB, if the pool metadata size is not specified.
-The value must be a multiple of 64KiB.
+pool metadata size within 128 MiB, if the pool metadata size is not specified.
+The value must be a multiple of 64 KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .
 .HP
@@ -1589,7 +1589,7 @@ answer yes. Use with extreme caution.
 .HP
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-For snapshots, this controls zeroing of the first 4KiB of data in the
+For snapshots, this controls zeroing of the first 4 KiB of data in the
 snapshot. If the LV is read-only, the snapshot will not be zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index 30e862d83..466470cb7 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -2,7 +2,7 @@
 .SH EXAMPLES
 .
 .P
-Create a striped LV with 3 stripes, a stripe size of 8KiB and a size of 100MiB.
+Create a striped LV with 3 stripes, a stripe size of 8 KiB and a size of 100 MiB.
 The LV name is chosen by lvcreate.
 .br
 .B lvcreate -i 3 -I 8 -L 100m vg00
@@ -33,17 +33,17 @@ for overwriting 20% of the size of the original LV.
 .br
 .B lvcreate -s -l 20%ORIGIN -n mysnap vg00/mylv
 .P
-Create a sparse LV with 1TiB of virtual space, and actual space just under
-100MiB.
+Create a sparse LV with 1 TiB of virtual space, and actual space just under
+100 MiB.
 .br
 .B lvcreate --snapshot --virtualsize 1t --size 100m --name mylv vg00
 .P
-Create a linear LV with a usable size of 64MiB on specific physical extents.
+Create a linear LV with a usable size of 64 MiB on specific physical extents.
 .br
 .B lvcreate -L 64m -n mylv vg00 /dev/sda:0-7 /dev/sdb:0-7
 .P
-Create a RAID5 LV with a usable size of 5GiB, 3 stripes, a stripe size of
-64KiB, using a total of 4 devices (including one for parity).
+Create a RAID5 LV with a usable size of 5 GiB, 3 stripes, a stripe size of
+64 KiB, using a total of 4 devices (including one for parity).
 .br
 .B lvcreate --type raid5 -L 5G -i 3 -I 64 -n mylv vg00
 .P
@@ -57,7 +57,7 @@ the VG, in which case \fB-i 7\fP must be used to get to the current maximum of
 .B --type raid5 -l 100%FREE -n mylv vg00
 .RE
 .P
-Create RAID10 LV with a usable size of 5GiB, using 2 stripes, each on
+Create RAID10 LV with a usable size of 5 GiB, using 2 stripes, each on
 a two-image mirror. (Note that the \fB-i\fP and \fB-m\fP arguments behave
 differently:
 \fB-i\fP specifies the total number of stripes,
@@ -66,13 +66,13 @@ to the first image).
 .br
 .B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
 .P
-Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
+Create a 1 TiB thin LV mythin, with 256 GiB thinpool tpool0 in vg00.
 .br
 .B lvcreate -T -V 1T --size 256G --name mythin vg00/tpool0
 .P
-Create a 1TiB thin LV, first creating a new thin pool for it, where
-the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
-size, and 256KiB chunk size.
+Create a 1 TiB thin LV, first creating a new thin pool for it, where
+the thin pool has 100 MiB of space, uses 2 stripes, has a 64 KiB stripe
+size, and 256 KiB chunk size.
 .br
 .B lvcreate --type thin --name mylv --thinpool mypool
 .RS
@@ -102,6 +102,6 @@ then combining the new origin LV with an existing cache pool.
 .B -L 100G -n mylv vg00 /dev/slow1
 .RE
 .P
-Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
+Create a VDO LV vdo0 with VDOPoolLV size of 10 GiB and name vpool1.
 .br
 .B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index efca91c19..3940aa77e 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -954,14 +954,14 @@ The name of a cache volume.
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
 The size of chunks in a snapshot, cache pool or thin pool.
-For snapshots, the value must be a power of 2 between 4KiB and 512KiB
+For snapshots, the value must be a power of 2 between 4 KiB and 512 KiB
 and the default value is 4.
-For a cache pool the value must be between 32KiB and 1GiB
+For a cache pool the value must be between 32 KiB and 1 GiB
 and the default value is 64.
-For a thin pool the value must be between 64KiB and 1GiB
+For a thin pool the value must be between 64 KiB and 1 GiB
 and the default value starts with 64 and scales up to fit the
-pool metadata size within 128MiB, if the pool metadata size is not specified.
-The value must be a multiple of 64KiB.
+pool metadata size within 128 MiB, if the pool metadata size is not specified.
+The value must be a multiple of 64 KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
 .
 .HP
@@ -1509,7 +1509,7 @@ answer yes. Use with extreme caution.
 .HP
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-Controls zeroing of the first 4KiB of data in the new LV.
+Controls zeroing of the first 4 KiB of data in the new LV.
 Default is \fBy\fP.
 Snapshot COW volumes are always zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 8b8289c74..d46c50d04 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -455,7 +455,7 @@ defines the default cache mode.
 .
 The size of data blocks managed by dm-cache can be specified with the
 --chunksize option when caching is started.  The default unit is KiB.  The
-value must be a multiple of 32KiB between 32KiB and 1GiB. Cache chunks
+value must be a multiple of 32 KiB between 32 KiB and 1 GiB. Cache chunks
 bigger then 512KiB shall be only used when necessary.
 .P
 Using a chunk size that is too large can result in wasteful use of the
@@ -495,9 +495,9 @@ account of normal io traffic going to the devices.
 .P
 User can set migration threshold via cache policy settings as
 "migration_threshold=<#sectors>" to set the maximum number
-of sectors being migrated, the default being 2048 sectors (1MiB).
+of sectors being migrated, the default being 2048 sectors (1 MiB).
 .P
-Command to set migration threshold to 2MiB (4096 sectors):
+Command to set migration threshold to 2 MiB (4096 sectors):
 .P
 .B lvcreate --cachepolicy 'migration_threshold=4096' VG/LV
 .P
diff --git a/man/pvcreate.8_end b/man/pvcreate.8_end
index 2dfb7ecb5..7ebf963bb 100644
--- a/man/pvcreate.8_end
+++ b/man/pvcreate.8_end
@@ -5,9 +5,9 @@ Initialize a partition and a full device.
 .br
 .B pvcreate /dev/sdc4 /dev/sde
 .P
-If a device is a 4KiB sector drive that compensates for windows
-partitioning (sector 7 is the lowest aligned logical block, the 4KiB
-sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
+If a device is a 4 KiB sector drive that compensates for windows
+partitioning (sector 7 is the lowest aligned logical block, the 4 KiB
+sectors start at LBA -1, and consequently sector 63 is aligned on a 4 KiB
 boundary) manually account for this when initializing for use by LVM.
 .br
 .B pvcreate --dataalignmentoffset 7s /dev/sdb
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 07626ee1b..d70f1e5ac 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -720,7 +720,7 @@ Metadata may not be changed with this option.
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
-currently used in the VG), or at least 128KiB.
+currently used in the VG), or at least 128 KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
 Before increasing the physical extent size, you might need to use lvresize,
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index d07741ffc..2c0c548b5 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -323,7 +323,7 @@ incorrect results.
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
-currently used in the VG), or at least 128KiB.
+currently used in the VG), or at least 128 KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
 .
diff --git a/tools/args.h b/tools/args.h
index baae333e1..2f94d4535 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1103,14 +1103,14 @@ arg(blockdevice_ARG, 'b', "blockdevice", 0, 0, 0,
 
 arg(chunksize_ARG, 'c', "chunksize", sizekb_VAL, 0, 0,
     "The size of chunks in a snapshot, cache pool or thin pool.\n"
-    "For snapshots, the value must be a power of 2 between 4KiB and 512KiB\n"
+    "For snapshots, the value must be a power of 2 between 4 KiB and 512 KiB\n"
     "and the default value is 4.\n"
-    "For a cache pool the value must be between 32KiB and 1GiB\n"
+    "For a cache pool the value must be between 32 KiB and 1 GiB\n"
     "and the default value is 64.\n"
-    "For a thin pool the value must be between 64KiB and 1GiB\n"
+    "For a thin pool the value must be between 64 KiB and 1 GiB\n"
     "and the default value starts with 64 and scales up to fit the\n"
-    "pool metadata size within 128MiB, if the pool metadata size is not specified.\n"
-    "The value must be a multiple of 64KiB.\n"
+    "pool metadata size within 128 MiB, if the pool metadata size is not specified.\n"
+    "The value must be a multiple of 64 KiB.\n"
     "See \\fBlvmthin\\fP(7) and \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(clustered_ARG, 'c', "clustered", bool_VAL, 0, 0,
@@ -1462,14 +1462,14 @@ arg(physicalextentsize_ARG, 's', "physicalextentsize", sizemb_VAL, 0, 0,
     "Sets the physical extent size of PVs in the VG.\n"
     "The value must be either a power of 2 of at least 1 sector\n"
     "(where the sector size is the largest sector size of the PVs\n"
-    "currently used in the VG), or at least 128KiB.\n"
+    "currently used in the VG), or at least 128 KiB.\n"
     "Once this value has been set, it is difficult to change\n"
     "without recreating the VG, unless no extents need moving.\n"
     "#vgchange\n"
     "Sets the physical extent size of PVs in the VG.\n"
     "The value must be either a power of 2 of at least 1 sector\n"
     "(where the sector size is the largest sector size of the PVs\n"
-    "currently used in the VG), or at least 128KiB.\n"
+    "currently used in the VG), or at least 128 KiB.\n"
     "Once this value has been set, it is difficult to change\n"
     "without recreating the VG, unless no extents need moving.\n"
     "Before increasing the physical extent size, you might need to use lvresize,\n"
@@ -1626,12 +1626,12 @@ arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "Set zeroing mode for thin pool. Note: already provisioned blocks from pool\n"
     "in non-zero mode are not cleared in unwritten parts when setting --zero y.\n"
     "#lvconvert\n"
-    "For snapshots, this controls zeroing of the first 4KiB of data in the\n"
+    "For snapshots, this controls zeroing of the first 4 KiB of data in the\n"
     "snapshot. If the LV is read-only, the snapshot will not be zeroed.\n"
     "For thin pools, this controls zeroing of provisioned blocks.\n"
     "Provisioning of large zeroed chunks negatively impacts performance.\n"
     "#lvcreate\n"
-    "Controls zeroing of the first 4KiB of data in the new LV.\n"
+    "Controls zeroing of the first 4 KiB of data in the new LV.\n"
     "Default is \\fBy\\fP.\n"
     "Snapshot COW volumes are always zeroed.\n"
     "For thin pools, this controls zeroing of provisioned blocks.\n"

