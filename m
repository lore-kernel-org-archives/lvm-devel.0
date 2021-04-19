From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:01:00 +0000 (GMT)
Subject: main - man: replace empty lines
Message-ID: <20210419130100.1CB1D396903B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1f8978ac5adbe7274faa62011dbb30a95719191
Commit:        d1f8978ac5adbe7274faa62011dbb30a95719191
Parent:        5f75f5e2bc0f10c74151914aa59264d29815d9ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 16 15:57:01 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:54:37 2021 +0200

man: replace empty lines

---
 man/lvchange.8_end        |  4 +++-
 man/lvconvert.8_des       | 28 ++++++++++++++--------------
 man/lvconvert.8_end       | 44 ++++++++++++++++++++++++--------------------
 man/lvcreate.8_des        | 22 +++++++++++-----------
 man/lvcreate.8_end        | 38 ++++++++++++++++++++------------------
 man/lvdisplay.8_des       |  2 +-
 man/lvextend.8_des        |  6 +++---
 man/lvextend.8_end        |  6 ++++--
 man/lvm-lvpoll.8_end      | 16 +++++++++-------
 man/lvm.8_main            |  2 +-
 man/lvmdevices.8_des      | 23 +++++++++++------------
 man/lvmdiskscan.8_des     |  3 +--
 man/lvreduce.8_des        |  6 +++---
 man/lvreduce.8_end        |  3 ++-
 man/lvremove.8_des        | 10 +++++-----
 man/lvremove.8_end        |  4 +++-
 man/lvrename.8_end        |  5 +++--
 man/lvresize.8_des        |  2 +-
 man/lvresize.8_end        |  3 ++-
 man/lvs.8_end             |  1 +
 man/pvchange.8_des        |  2 +-
 man/pvchange.8_end        |  3 ++-
 man/pvck.8_des            | 47 +++++++++++++++++++++++------------------------
 man/pvck.8_end            |  3 ++-
 man/pvcreate.8_des        | 24 ++++++++++++------------
 man/pvcreate.8_end        |  5 +++--
 man/pvdisplay.8_des       |  2 +-
 man/pvmove.8_des          |  4 ++--
 man/pvmove.8_end          | 38 ++++++++++++++++++++------------------
 man/pvremove.8_des        |  4 ++--
 man/pvresize.8_end        |  6 +++++-
 man/pvs.8_end             |  1 +
 man/pvscan.8_des          | 33 ++++++++++++++++-----------------
 man/vgcfgbackup.8_des     |  8 ++++----
 man/vgcfgrestore.8_des    |  4 ++--
 man/vgcfgrestore.8_end    |  3 ++-
 man/vgchange.8_end        |  6 +++++-
 man/vgcreate.8_des        |  3 +--
 man/vgcreate.8_end        |  3 ++-
 man/vgdisplay.8_des       |  2 +-
 man/vgexport.8_des        |  8 ++++----
 man/vgextend.8_des        |  4 ++--
 man/vgextend.8_end        |  3 ++-
 man/vgimport.8_des        |  2 +-
 man/vgimportclone.8_des   |  2 +-
 man/vgimportclone.8_end   |  3 ++-
 man/vgimportdevices.8_des |  3 +--
 man/vgmerge.8_end         |  3 ++-
 man/vgmknodes.8_des       |  2 +-
 man/vgremove.8_des        |  4 ++--
 man/vgrename.8_des        |  2 +-
 man/vgrename.8_end        |  5 +++--
 man/vgs.8_end             |  1 +
 man/vgsplit.8_des         |  8 ++++----
 54 files changed, 256 insertions(+), 223 deletions(-)

diff --git a/man/lvchange.8_end b/man/lvchange.8_end
index e3087d7fc..e6d44c52f 100644
--- a/man/lvchange.8_end
+++ b/man/lvchange.8_end
@@ -1,4 +1,6 @@
+.
 .SH EXAMPLES
+.
 Change LV permission to read-only:
-.sp
+.br
 .B lvchange -pr vg00/lvol1
diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index cc233fb1d..f36135f21 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -1,42 +1,42 @@
 lvconvert changes the LV type and includes utilities for LV data
 maintenance. The LV type controls data layout and redundancy.
 The LV type is also called the segment type or segtype.
-
+.P
 To display the current LV type, run the command:
-
+.P
 .B lvs -o name,segtype
 .I LV
-
+.P
 In some cases, an LV is a single device mapper (dm) layer above physical
 devices.  In other cases, hidden LVs (dm devices) are layered between the
 visible LV and physical devices.  LVs in the middle layers are called sub LVs.
 A command run on a visible LV sometimes operates on a sub LV rather than
 the specified LV.  In other cases, a sub LV must be specified directly on
 the command line.
-
+.P
 Sub LVs can be displayed with the command:
-
+.P
 .B lvs -a
-
+.P
 The
 .B linear
 type is equivalent to the
 .B striped
 type when one stripe exists.
 In that case, the types can sometimes be used interchangably.
-
+.P
 In most cases, the
 .B mirror
 type is deprecated and the
 .B raid1
 type should be used.  They are both implementations of mirroring.
-
+.P
 Striped raid types are
 \fBraid0/raid0_meta\fP,
 \fBraid5\fP (an alias for raid5_ls),
 \fBraid6\fP (an alias for raid6_zr) and
 \fBraid10\fP (an alias for raid10_near).
-
+.P
 As opposed to mirroring, raid5 and raid6 stripe data and calculate parity
 blocks. The parity blocks can be used for data block recovery in case
 devices fail. A maximum number of one device in a raid5 LV may fail, and
@@ -45,27 +45,27 @@ data blocks for performance reasons, thus avoiding contention on a single
 device. Specific arrangements of parity and data blocks (layouts) can be
 used to optimize I/O performance, or to convert between raid levels.  See
 \fBlvmraid\fP(7) for more information.
-
+.P
 Layouts of raid5 rotating parity blocks can be: left-asymmetric
 (raid5_la), left-symmetric (raid5_ls with alias raid5), right-asymmetric
 (raid5_ra), right-symmetric (raid5_rs) and raid5_n, which doesn't rotate
 parity blocks. Layouts of raid6 are: zero-restart (raid6_zr with alias
 raid6), next-restart (raid6_nr), and next-continue (raid6_nc).
-
+.P
 Layouts including _n allow for conversion between raid levels (raid5_n to
 raid6 or raid5_n to striped/raid0/raid0_meta). Additionally, special raid6
 layouts for raid level conversions between raid5 and raid6 are:
 raid6_ls_6, raid6_rs_6, raid6_la_6 and raid6_ra_6. Those correspond to
 their raid5 counterparts (e.g. raid5_rs can be directly converted to
 raid6_rs_6 and vice-versa).
-
+.P
 raid10 (an alias for raid10_near) is currently limited to one data copy
 and even number of sub LVs. This is a mirror group layout, thus a single
 sub LV may fail per mirror group without data loss.
-
+.P
 Striped raid types support converting the layout, their stripesize and
 their number of stripes.
-
+.P
 The striped raid types combined with raid1 allow for conversion from
 linear \[->] striped/raid0/raid0_meta and vice-versa by e.g. linear \[<>] raid1
 \[<>] raid5_n (then adding stripes) \[<>] striped/raid0/raid0_meta.
diff --git a/man/lvconvert.8_end b/man/lvconvert.8_end
index 1087c6ed4..97495067c 100644
--- a/man/lvconvert.8_end
+++ b/man/lvconvert.8_end
@@ -1,4 +1,6 @@
+.
 .SH NOTES
+.
 This previous command syntax would perform two different operations:
 .br
 \fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
@@ -7,7 +9,7 @@ If LV1 was not a thin pool, the command would convert LV1 to
 a thin pool, optionally using a specified LV for metadata.
 But, if LV1 was already a thin pool, the command would swap
 the current metadata LV with LV2 (for repair purposes.)
-
+.P
 In the same way, this previous command syntax would perform two different
 operations:
 .br
@@ -17,74 +19,76 @@ If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
 But, if LV1 was already a cache pool, the command would swap
 the current metadata LV with LV2 (for repair purposes.)
+.
 .SH EXAMPLES
+.
 Convert a linear LV to a two-way mirror LV.
 .br
 .B lvconvert --type mirror --mirrors 1 vg/lvol1
-
+.P
 Convert a linear LV to a two-way RAID1 LV.
 .br
 .B lvconvert --type raid1 --mirrors 1 vg/lvol1
-
+.P
 Convert a mirror LV to use an in-memory log.
 .br
 .B lvconvert --mirrorlog core vg/lvol1
-
+.P
 Convert a mirror LV to use a disk log.
 .br
 .B lvconvert --mirrorlog disk vg/lvol1
-
+.P
 Convert a mirror or raid1 LV to a linear LV.
 .br
 .B lvconvert --type linear vg/lvol1
-
+.P
 Convert a mirror LV to a raid1 LV with the same number of images.
 .br
 .B lvconvert --type raid1 vg/lvol1
-
+.P
 Convert a linear LV to a two-way mirror LV, allocating new extents from specific
 PV ranges.
 .br
 .B lvconvert --mirrors 1 vg/lvol1 /dev/sda:0-15 /dev/sdb:0-15
-
+.P
 Convert a mirror LV to a linear LV, freeing physical extents from a specific PV.
 .br
 .B lvconvert --type linear vg/lvol1 /dev/sda
-
+.P
 Split one image from a mirror or raid1 LV, making it a new LV.
 .br
 .B lvconvert --splitmirrors 1 --name lv_split vg/lvol1
-
+.P
 Split one image from a raid1 LV, and track changes made to the raid1 LV
 while the split image remains detached.
 .br
 .B lvconvert --splitmirrors 1 --trackchanges vg/lvol1
-
+.P
 Merge an image (that was previously created with --splitmirrors and
 --trackchanges) back into the original raid1 LV.
 .br
 .B lvconvert --mergemirrors vg/lvol1_rimage_1
-
+.P
 Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV.
 .br
 .B lvconvert --replace /dev/sdb1 vg/lvol1 /dev/sdf1
-
+.P
 Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV.
 .br
 .B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 --replace /dev/sdd1
 .RS
 .B vg/lvol1 /dev/sd[fgh]1
 .RE
-
+.P
 Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV.
 .br
 .B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
-
+.P
 Convert an LV into a thin LV in the specified thin pool.  The existing LV
 is used as an external read-only origin for the new thin LV.
 .br
 .B lvconvert --type thin --thinpool vg/tpool1 vg/lvol1
-
+.P
 Convert an LV into a thin LV in the specified thin pool.  The existing LV
 is used as an external read-only origin for the new thin LV, and is
 renamed "external".
@@ -93,20 +97,20 @@ renamed "external".
 .RS
 .B --originname external vg/lvol1
 .RE
-
+.P
 Convert an LV to a cache pool LV using another specified LV for cache pool
 metadata.
 .br
 .B lvconvert --type cache-pool --poolmetadata vg/poolmeta1 vg/lvol1
-
+.P
 Convert an LV to a cache LV using the specified cache pool and chunk size.
 .br
 .B lvconvert --type cache --cachepool vg/cpool1 -c 128 vg/lvol1
-
+.P
 Detach and keep the cache pool from a cache LV.
 .br
 .B lvconvert --splitcache vg/lvol1
-
+.P
 Detach and remove the cache pool from a cache LV.
 .br
 .B lvconvert --uncache vg/lvol1
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index 7bb2bb61a..4f7e712fe 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -2,45 +2,45 @@ lvcreate creates a new LV in a VG. For standard LVs, this requires
 allocating logical extents from the VG's free physical extents. If there
 is not enough free space, the VG can be extended with other PVs
 (\fBvgextend\fP(8)), or existing LVs can be reduced or removed
-(\fBlvremove\fP(8), \fBlvreduce\fP(8).)
-
+(\fBlvremove\fP(8), \fBlvreduce\fP(8)).
+.P
 To control which PVs a new LV will use, specify one or more PVs as
 position args at the end of the command line. lvcreate will allocate
 physical extents only from the specified PVs.
-
+.P
 lvcreate can also create snapshots of existing LVs, e.g. for backup
 purposes. The data in a new snapshot LV represents the content of the
 original LV from the time the snapshot was created.
-
+.P
 RAID LVs can be created by specifying an LV type when creating the LV (see
 \fBlvmraid\fP(7)). Different RAID levels require different numbers of
 unique PVs be available in the VG for allocation.
-
+.P
 Thin pools (for thin provisioning) and cache pools (for caching) are
 represented by special LVs with types thin-pool and cache-pool (see
 \fBlvmthin\fP(7) and \fBlvmcache\fP(7)). The pool LVs are not usable as
 standard block devices, but the LV names act as references to the pools.
-
+.P
 Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
-
+.P
 VDO LVs are also provisioned volumes from a VDO pool, and are created with a
 virtual size rather than a physical size (see \fBlvmvdo\fP(7)).
-
+.P
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP. See descriptions in the options section.
-
+.P
 In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used. When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.
-
+.P
 In the usage section below, when creating a pool and the name is omitted
 the new LV pool name is generated with the
 "vpool" for vdo-pools  for prefix and a unique numeric suffix.
-
+.P
 Pool name can be specified together with \fIVG\fP name i.e.:
 vg00/mythinpool.
diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index 9be3426da..30e862d83 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -1,50 +1,52 @@
+.
 .SH EXAMPLES
-
+.
+.P
 Create a striped LV with 3 stripes, a stripe size of 8KiB and a size of 100MiB.
 The LV name is chosen by lvcreate.
 .br
 .B lvcreate -i 3 -I 8 -L 100m vg00
-
+.P
 Create a raid1 LV with two images, and a useable size of 500 MiB. This
 operation requires two devices, one for each mirror image. RAID metadata
 (superblock and bitmap) is also included on the two devices.
 .br
 .B lvcreate --type raid1 -m1 -L 500m -n mylv vg00
-
+.P
 Create a mirror LV with two images, and a useable size of 500 MiB.
 This operation requires three devices: two for mirror images and
 one for a disk log.
 .br
 .B lvcreate --type mirror -m1 -L 500m -n mylv vg00
-
+.P
 Create a mirror LV with 2 images, and a useable size of 500 MiB.
 This operation requires 2 devices because the log is in memory.
 .br
 .B lvcreate --type mirror -m1 --mirrorlog core -L 500m -n mylv vg00
-
+.P
 Create a copy-on-write snapshot of an LV:
 .br
 .B lvcreate --snapshot --size 100m --name mysnap vg00/mylv
-
+.P
 Create a copy-on-write snapshot with a size sufficient
 for overwriting 20% of the size of the original LV.
 .br
 .B lvcreate -s -l 20%ORIGIN -n mysnap vg00/mylv
-
+.P
 Create a sparse LV with 1TiB of virtual space, and actual space just under
 100MiB.
 .br
 .B lvcreate --snapshot --virtualsize 1t --size 100m --name mylv vg00
-
+.P
 Create a linear LV with a usable size of 64MiB on specific physical extents.
 .br
 .B lvcreate -L 64m -n mylv vg00 /dev/sda:0-7 /dev/sdb:0-7
-
+.P
 Create a RAID5 LV with a usable size of 5GiB, 3 stripes, a stripe size of
 64KiB, using a total of 4 devices (including one for parity).
 .br
 .B lvcreate --type raid5 -L 5G -i 3 -I 64 -n mylv vg00
-
+.P
 Create a RAID5 LV using all of the free space in the VG and spanning all the
 PVs in the VG (note that the command will fail if there are more than 8 PVs in
 the VG, in which case \fB-i 7\fP must be used to get to the current maximum of
@@ -54,7 +56,7 @@ the VG, in which case \fB-i 7\fP must be used to get to the current maximum of
 .RS
 .B --type raid5 -l 100%FREE -n mylv vg00
 .RE
-
+.P
 Create RAID10 LV with a usable size of 5GiB, using 2 stripes, each on
 a two-image mirror. (Note that the \fB-i\fP and \fB-m\fP arguments behave
 differently:
@@ -63,11 +65,11 @@ but \fB-m\fP specifies the number of images in addition
 to the first image).
 .br
 .B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
-
+.P
 Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
 .br
 .B lvcreate -T -V 1T --size 256G --name mythin vg00/tpool0
-
+.P
 Create a 1TiB thin LV, first creating a new thin pool for it, where
 the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
 size, and 256KiB chunk size.
@@ -76,22 +78,22 @@ size, and 256KiB chunk size.
 .RS
 .B -V 1t -L 100m -i 2 -I 64 -c 256 vg00
 .RE
-
+.P
 Create a thin snapshot of a thin LV (the size option must not be
 used, otherwise a copy-on-write snapshot would be created).
 .br
 .B lvcreate --snapshot --name mysnap vg00/thinvol
-
+.P
 Create a thin snapshot of the read-only inactive LV named "origin"
 which becomes an external origin for the thin snapshot LV.
 .br
 .B lvcreate --snapshot --name mysnap --thinpool mypool vg00/origin
-
+.P
 Create a cache pool from a fast physical device. The cache pool can
 then be used to cache an LV.
 .br
 .B lvcreate --type cache-pool -L 1G -n my_cpool vg00 /dev/fast1
-
+.P
 Create a cache LV, first creating a new origin LV on a slow physical device,
 then combining the new origin LV with an existing cache pool.
 .br
@@ -99,7 +101,7 @@ then combining the new origin LV with an existing cache pool.
 .RS
 .B -L 100G -n mylv vg00 /dev/slow1
 .RE
-
+.P
 Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
 .br
 .B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1
diff --git a/man/lvdisplay.8_des b/man/lvdisplay.8_des
index 48552cc95..ee004b185 100644
--- a/man/lvdisplay.8_des
+++ b/man/lvdisplay.8_des
@@ -1,5 +1,5 @@
 lvdisplay shows the attributes of LVs, like size, read/write status,
 snapshot information, etc.
-
+.P
 \fBlvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
diff --git a/man/lvextend.8_des b/man/lvextend.8_des
index eafd24755..6fc6a8ddd 100644
--- a/man/lvextend.8_des
+++ b/man/lvextend.8_des
@@ -1,12 +1,12 @@
 lvextend extends the size of an LV. This requires allocating logical
 extents from the VG's free physical extents. If the extension adds a new
 LV segment, the new segment will use the existing segment type of the LV.
-
+.P
 Extending a copy-on-write snapshot LV adds space for COW blocks.
-
+.P
 Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvextend.8_end b/man/lvextend.8_end
index af24d4f80..3cffe1d25 100644
--- a/man/lvextend.8_end
+++ b/man/lvextend.8_end
@@ -1,14 +1,16 @@
+.
 .SH EXAMPLES
+.
 Extend the size of an LV by 54MiB, using a specific PV.
 .br
 .B lvextend -L +54 vg01/lvol10 /dev/sdk3
-
+.P
 Extend the size of an LV by the amount of free
 space on PV /dev/sdk3. This is equivalent to specifying
 "-l +100%PVS" on the command line.
 .br
 .B lvextend vg01/lvol01 /dev/sdk3
-
+.P
 Extend an LV by 16MiB using specific physical extents.
 .br
 .B lvextend -L+16m vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
diff --git a/man/lvm-lvpoll.8_end b/man/lvm-lvpoll.8_end
index d38dfd0f3..6706a3e8f 100644
--- a/man/lvm-lvpoll.8_end
+++ b/man/lvm-lvpoll.8_end
@@ -1,31 +1,33 @@
+.
 .SH NOTES
-
+.
 To find the name of the pvmove LV that was created by an original
 \fBpvmove /dev/name\fP command, use the command:
 .br
 \fBlvs -a -S move_pv=/dev/name\fP.
+.
 .SH EXAMPLES
-
+.
 Continue polling a pvmove operation.
 .br
 .B lvm lvpoll --polloperation pvmove vg00/pvmove0
-
+.P
 Abort a pvmove operation.
 .br
 .B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
-
+.P
 Continue polling a mirror conversion.
 .br
 .B lvm lvpoll --polloperation convert vg00/lvmirror
-
+.P
 Continue mirror repair.
 .br
 .B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
-
+.P
 Continue snapshot merge.
 .br
 .B lvm lvpoll --polloperation merge vg/snapshot_old
-
+.P
 Continue thin snapshot merge.
 .br
 .B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 509a635ef..234442e64 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -328,7 +328,7 @@ UUID of the intended VG: --select vg_uuid=<uuid>
 .P
 An exception is if all but one of the VGs with the shared name is foreign
 (see
-.BR lvmsystemid (7).)
+.BR lvmsystemid (7)).
 In this case, the one VG that is not foreign is assumed to be the intended
 VG and is processed.
 .P
diff --git a/man/lvmdevices.8_des b/man/lvmdevices.8_des
index 52885fb59..015aa1122 100644
--- a/man/lvmdevices.8_des
+++ b/man/lvmdevices.8_des
@@ -2,18 +2,18 @@ The LVM devices file lists devices that lvm can use.  The default file is
 \fI#DEFAULT_SYS_DIR#/devices/system.devices\fP, and the \fBlvmdevices\fP(8) command is used to
 add or remove device entries.  If the file does not exist, or if lvm.conf
 includes use_devicesfile=0, then lvm will not use a devices file.
-
+.P
 To use a device with lvm, add it to the devices file with the command
 lvmdevices --adddev, and to prevent lvm from seeing or using a device,
 remove it from the devices file with lvmdevices --deldev.  The
 vgimportdevices(8) command adds all PVs from a VG to the devices file,
 and updates the VG metadata to include device IDs of the PVs.
-
+.P
 Commands adding new devices to the devices file necessarily look outside
 the existing devices file to find the devices to add.  pvcreate, vgcreate,
 and vgextend also look outside the devices file to create new PVs and add
 them to the devices file.
-
+.P
 LVM records devices in the devices file using hardware-specific IDs, such
 as the WWID, and attempts to use subsystem-specific IDs for virtual device
 types (which also aim to be as unique and stable as possible.)
@@ -21,42 +21,41 @@ These device IDs are also written in the VG metadata.  When no hardware or
 virtual ID is available, lvm falls back using the unstable device name as
 the device ID.  When devnames are used, lvm performs extra scanning to
 find devices if their devname changes, e.g. after reboot.
-
+.P
 When proper device IDs are used, an lvm command will not look at devices
 outside the devices file, but when devnames are used as a fallback, lvm
 will scan devices outside the devices file to locate PVs on renamed
 devices.  A config setting search_for_devnames can be used to control the
 scanning for renamed devname entries.
-
+.P
 Related to the devices file, the new command option --devices <devnames>
 allows a list of devices to be specified for the command to use,
 overriding the devices file.  The listed devices act as a sort of devices
 file in terms of limiting which devices lvm will see and use.  Devices
 that are not listed will appear to be missing to the lvm command.
-    
+.P
 Multiple devices files can be kept in \fI#DEFAULT_SYS_DIR#/devices\fP, which allows lvm
 to be used with different sets of devices, e.g. system devices do not need
 to be exposed to a specific application, and the application can use lvm on
 its own devices that are not exposed to the system.  The option
 --devicesfile <filename> is used to select the devices file to use with the
 command.  Without the option set, the default system devices file is used.
-
+.P
 Setting --devicesfile "" causes lvm to not use a devices file.
-
+.P
 With no devices file, lvm will use any device on the system, and applies
 the filter to limit the full set of system devices.  With a devices file,
 the regex filter is not used, and the filter settings in lvm.conf or the
 command line are ignored.  The vgimportdevices command is one exception
 which does apply the regex filter when looking for a VG to import.
-
+.P
 If a devices file exists, lvm will use it, even if it's empty.  An empty
 devices file means lvm will see no devices.
-
+.P
 If the system devices file does not yet exist, the pvcreate or vgcreate
 commands will create it if they see no existing VGs on the system.
 lvmdevices --addev and vgimportdevices will always create a new devices file
 if it does not yet exist.
-
+.P
 It is recommended to use lvm commands to make changes to the devices file to
 ensure proper updates.
-
diff --git a/man/lvmdiskscan.8_des b/man/lvmdiskscan.8_des
index c1e87cca5..70df55d31 100644
--- a/man/lvmdiskscan.8_des
+++ b/man/lvmdiskscan.8_des
@@ -2,6 +2,5 @@ lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch of
 other block devices in the system looking for LVM PVs. The size reported
 is the real device size. Define a filter in \fBlvm.conf\fP(5) to restrict
 the scan to avoid a CD ROM, for example.
-
+.P
 This command is deprecated, use \fBpvs\fP instead.
-
diff --git a/man/lvreduce.8_des b/man/lvreduce.8_des
index af6735843..5a7d4e92f 100644
--- a/man/lvreduce.8_des
+++ b/man/lvreduce.8_des
@@ -3,16 +3,16 @@ to the VG to be used by other LVs. A copy-on-write snapshot LV can also
 be reduced if less space is needed to hold COW blocks. Use
 \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
-
+.P
 Be careful when reducing an LV's size, because data in the reduced area is
 lost. Ensure that any file system on the LV is resized \fBbefore\fP
 running lvreduce so that the removed extents are not in use by the file
 system.
-
+.P
 Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvreduce.8_end b/man/lvreduce.8_end
index 53f1ac78e..a92e77222 100644
--- a/man/lvreduce.8_end
+++ b/man/lvreduce.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Reduce the size of an LV by 3 logical extents:
 .br
 .B lvreduce -l -3 vg00/lvol1
diff --git a/man/lvremove.8_des b/man/lvremove.8_des
index a9b481307..9e8f78d00 100644
--- a/man/lvremove.8_des
+++ b/man/lvremove.8_des
@@ -1,18 +1,18 @@
 lvremove removes one or more LVs. For standard LVs, this returns the
 logical extents that were used by the LV to the VG for use by other LVs.
-
+.P
 Confirmation will be requested before deactivating any active LV prior to
 removal.  LVs cannot be deactivated or removed while they are open (e.g.
 if they contain a mounted filesystem). Removing an origin LV will also
 remove all dependent snapshots.
-
+.P
 When a single force option is used, LVs are removed without confirmation,
 and the command will try to deactivate unused LVs.
-
+.P
 To remove damaged LVs, two force options may be required (\fB-ff\fP).
-
+.P
 \fBHistorical LVs\fP
-
+.P
 If the configuration setting \fBmetadata/record_lvs_history\fP is enabled
 and the LV being removed forms part of the history of at least one LV that
 is still present, then a simplified representation of the LV will be
diff --git a/man/lvremove.8_end b/man/lvremove.8_end
index e74601564..1f0c80103 100644
--- a/man/lvremove.8_end
+++ b/man/lvremove.8_end
@@ -1,8 +1,10 @@
+.
 .SH EXAMPLES
+.
 Remove an active LV without asking for confirmation.
 .br
 .B lvremove -f vg00/lvol1
-
+.P
 Remove all LVs the specified VG.
 .br
 .B lvremove vg00
diff --git a/man/lvrename.8_end b/man/lvrename.8_end
index ab7c7bd3d..386faabbb 100644
--- a/man/lvrename.8_end
+++ b/man/lvrename.8_end
@@ -1,9 +1,10 @@
+.
 .SH EXAMPLES
-
+.
 Rename "lvold" to "lvnew":
 .br
 .B lvrename /dev/vg02/lvold vg02/lvnew
-
+.P
 An alternate syntax to rename "lvold" to "lvnew":
 .br
 .B lvrename vg02 lvold lvnew
diff --git a/man/lvresize.8_des b/man/lvresize.8_des
index dcc42aa0d..2ff5e563b 100644
--- a/man/lvresize.8_des
+++ b/man/lvresize.8_des
@@ -1,6 +1,6 @@
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
-
+.P
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvresize.8_end b/man/lvresize.8_end
index 563ea5716..b69d6acd3 100644
--- a/man/lvresize.8_end
+++ b/man/lvresize.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Extend an LV by 16MB using specific physical extents:
 .br
 .B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
diff --git a/man/lvs.8_end b/man/lvs.8_end
index 6fdb80459..dc3a27446 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -1,3 +1,4 @@
+.
 .SH NOTES
 .
 The lv_attr bits are:
diff --git a/man/pvchange.8_des b/man/pvchange.8_des
index e914e1373..d67bca12b 100644
--- a/man/pvchange.8_des
+++ b/man/pvchange.8_des
@@ -1,4 +1,4 @@
 pvchange changes PV attributes in the VG.
-
+.P
 For options listed in parentheses, any one is required, after which the
 others are optional.
diff --git a/man/pvchange.8_end b/man/pvchange.8_end
index f1cac15a3..617f828c1 100644
--- a/man/pvchange.8_end
+++ b/man/pvchange.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Disallow the allocation of physical extents on a PV (e.g. because of
 disk errors, or because it will be removed after freeing it).
 .br
diff --git a/man/pvck.8_des b/man/pvck.8_des
index 1d9b30a02..3adda4672 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -1,7 +1,7 @@
 pvck checks and repairs LVM metadata on PVs.
-
+.P
 .SS Dump options 
-
+.P
 .B headers
 .br
 Print LVM on-disk headers and structures: label_header, pv_header,
@@ -12,7 +12,7 @@ a 512 byte sector at offset 4096 bytes.  A second mda_header can
 optionally exist near the end of the device.  The metadata text exists in
 an area (about 1MiB by default) immediately following the mda_header
 sector.  The metadata text is checked but not printed (see other options).
-
+.P
 .B metadata
 .br
 Print the current LVM VG metadata text (or save to a file), using headers
@@ -20,7 +20,7 @@ to locate the latest copy of metadata.  If headers are damaged, metadata
 may not be found (see metadata_search).  Use --settings "mda_num=2" to
 look in mda2 (the second mda at the end of the device, if used).  The
 metadata text is printed to stdout or saved to a file with --file.
-
+.P
 .B metadata_all
 .br
 List all versions of VG metadata found in the metadata area, using headers
@@ -28,7 +28,7 @@ to locate metadata.  Full copies of all metadata are saved to a file with
 the --file option.  If headers are damaged, metadata may not be found (see
 metadata_search).  Use --settings "mda_num=2" as above.  Use -v to include
 descriptions and dates when listing metadata versions.
-
+.P
 .B metadata_search
 .br
 List all versions of VG metadata found in the metadata area, searching
@@ -38,20 +38,20 @@ save one specific version of metadata, use --settings
 "metadata_offset=<offset>", where the offset is taken from the list of
 versions found.  Use -v to include descriptions and dates when listing
 metadata versions.
-
+.P
 .B metadata_area
 .br
 Save the entire text metadata area to a file without processing.
-
+.P
 .SS Repair options
-
+.P
 .B --repair
 .br
 Repair headers and metadata on a PV.  This uses a metadata input file that
 was extracted by --dump, or a backup file (from \fI#DEFAULT_BACKUP_DIR#\fP).  When
 possible, use metadata saved by --dump from another PV in the same VG (or
 from a second metadata area on the PV).
-
+.P
 There are cases where the PV UUID needs to be specified for the PV being
 repaired.  It is specified using --settings "pv_uuid=<UUID>".  In
 particular, if the device name for the PV being repaired does not match
@@ -60,52 +60,52 @@ the correct PV UUID.  When headers are damaged on more than one PV in a
 VG, it is important for the user to determine the correct PV UUID and
 specify it in --settings.  Otherwise, the wrong PV UUID could be used if
 device names have been swapped since the metadata was last written.
-
+.P
 If a PV has no metadata areas and the pv_header is damaged, then the
 repair will not know to create no metadata areas during repair.  It will
 by default repair metadata in mda1.  To repair with no metadata areas, use
 --settings "mda_offset=0 mda_size=0".
-
+.P
 There are cases where repair should be run on all PVs in the VG (using the
 same metadata file):  if all PVs in the VG are damaged, if using an old
 metadata version, or if a backup file is used instead of raw metadata
 (taken from pvck dump.)
-
+.P
 Using --repair is equivalent to running --repairtype pv_header followed by
 --repairtype metadata.
-
+.P
 .B --repairtype pv_header
 .br
 Repairs the header sector, containing the pv_header and label_header.
-
+.P
 .B --repairtype metadata
 .br
 Repairs the mda_header and metadata text.  It requires the headers to be
 correct (having been undamaged or already repaired).
-
+.P
 .B --repairtype label_header
 .br
 Repairs label_header fields, leaving the pv_header (in the same sector)
 unchanged.  (repairtype pv_header should usually be used instead.)
-
+.P
 .SS Settings
-
+.P
 The --settings option controls or overrides certain dump or repair
 behaviors.  All offset and size values in settings are in bytes (units are
 not recognized.)  These settings are subject to change.
-
+.P
 .B mda_num=1|2
 .br
 Select which metadata area should be used.  By default the first metadata
 area (1) is used.  mda1 is always located at offset 4096.  mda2, at the
 end of the device, often does not exist (it's not created by default.) If
 mda1 is erased, mda2, if it exists, will often still have metadata.
-
+.P
 \fBmetadata_offset=\fP\fIbytes\fP
 .br
 Select metadata text at this offset.  Use with metadata_search to
 print/save one instance of metadata text.
-
+.P
 \fBmda_offset=\fP\fIbytes\fP \fBmda_size=\fP\fIbytes\fP
 .br
 Refers to a metadata area (mda) location and size.  An mda includes an
@@ -113,18 +113,18 @@ mda_header and circular metadata text buffer.  Setting this forces
 metadata_search look for metadata in the given area instead of the
 standard locations.  When set to zero with repair, it indicates no
 metadata areas should exist.
-
+.P
 \fBmda2_offset=\fP\fIbytes\fP \fBmda2_size=\fP\fIbytes\fP
 .br
 When repairing a pv_header, this forces a specific offset and size for
 mda2 that should be recorded in the pv_header.
-
+.P
 \fBpv_uuid=\fP\fIuuid\fP
 .br
 Specify the PV UUID of the device being repaired.  When not specified,
 repair will attempt to determine the correct PV UUID by matching a device
 name in the metadata.
-
+.P
 \fBdevice_size=\fP\fIbytes\fP
 .br
 \fBdata_offset=\fP\fIbytes\fP
@@ -134,4 +134,3 @@ be specified directly, in which case these values are not taken from a
 metadata file (where they usually come from), and the metadata file can be
 omitted.  data_offset is the starting location of the first physical
 extent (data), which follows the first metadata area.
-
diff --git a/man/pvck.8_end b/man/pvck.8_end
index 4b9c6d0f6..2d05dccaa 100644
--- a/man/pvck.8_end
+++ b/man/pvck.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 If the partition table is corrupted or lost on /dev/sda, and you suspect
 there was an LVM partition at approximately 100 MiB, then this
 area of the disk can be scanned using the \fB--labelsector\fP
diff --git a/man/pvcreate.8_des b/man/pvcreate.8_des
index 22fb26bf3..69bd133aa 100644
--- a/man/pvcreate.8_des
+++ b/man/pvcreate.8_des
@@ -2,25 +2,25 @@ pvcreate initializes a Physical Volume (PV) on a device so the device is
 recognized as belonging to LVM.  This allows the PV to be used in a Volume
 Group (VG).  An LVM disk label is written to the device, and LVM metadata
 areas are initialized.  A PV can be placed on a whole device or partition.
-
+.P
 Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
 to add the PV to an existing VG.  Use \fBpvremove\fP(8) to remove the LVM
 disk label from the device.
-
+.P
 The force option will create a PV without confirmation.  Repeating the
 force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
 normally prevent it, e.g. if the PV is already in a VG.
-
+.P
 .B Metadata location, size, and alignment
-
+.P
 The LVM disk label begins 512 bytes from the start of the device, and is
 512 bytes in size.
-
+.P
 The LVM metadata area begins at an offset (from the start of the device)
 equal to the page size of the machine creating the PV (often 4 KiB.) The
 metadata area contains a 512 byte header and a multi-KiB circular buffer
 that holds text copies of the VG metadata.
-
+.P
 With default settings, the first physical extent (PE), which contains LV
 data, is 1 MiB from the start of the device.  This location is controlled
 by \fBdefault_data_alignment\fP in lvm.conf, which is set to 1 (MiB) by
@@ -29,7 +29,7 @@ can be checked with:
 .br
 .B pvs -o pe_start
 .I PV
-
+.P
 The size of the LVM metadata area is the space between the the start of
 the metadata area and the first PE.  When metadata begins at 4 KiB and the
 first PE is at 1024 KiB, the metadata area size is 1020 KiB.  This can be
@@ -37,7 +37,7 @@ checked with:
 .br
 .B pvs -o mda_size
 .I PV
-
+.P
 The mda_size cannot be increased after pvcreate, so if larger metadata is
 needed, it must be set during pvcreate.  Two copies of the VG metadata
 must always fit within the metadata area, so the maximum VG metadata size
@@ -45,7 +45,7 @@ is around half the mda_size.  This can be checked with:
 .br
 .B vgs -o mda_free
 .I VG
-
+.P
 A larger metadata area can be set with --metadatasize.  The resulting
 mda_size may be larger than specified due to default_data_alignment
 placing pe_start on a MiB boundary, and the fact that the metadata area
@@ -53,12 +53,12 @@ extends to the first PE.  With metadata starting at 4 KiB and
 default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
 pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
 2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
-
+.P
 The alignment of pe_start described above may be automatically overridden
 based on md device properties or device i/o properties reported in sysfs.
 These automatic adjustments can be enabled/disabled using lvm.conf
 settings md_chunk_alignment and data_alignment_offset_detection.
-
+.P
 To use a different pe_start alignment, use the --dataalignment option.
 The --metadatasize option would also typically be used in this case
 because the metadata area size also determines the location of pe_start.
@@ -71,7 +71,7 @@ The pe_start of 2176 KiB is the nearest even multiple of 128 KiB that
 provides at least 2048 KiB of metadata space.
 Always check the resulting alignment and metadata size when using
 these options.
-
+.P
 To shift an aligned pe_start value, use the --dataalignmentoffset option.
 The pe_start alignment is calculated as described above, and then the
 value specified with --dataalignmentoffset is added to produce the final
diff --git a/man/pvcreate.8_end b/man/pvcreate.8_end
index e89decd49..2dfb7ecb5 100644
--- a/man/pvcreate.8_end
+++ b/man/pvcreate.8_end
@@ -1,9 +1,10 @@
+.
 .SH EXAMPLES
-
+.
 Initialize a partition and a full device.
 .br
 .B pvcreate /dev/sdc4 /dev/sde
-
+.P
 If a device is a 4KiB sector drive that compensates for windows
 partitioning (sector 7 is the lowest aligned logical block, the 4KiB
 sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
diff --git a/man/pvdisplay.8_des b/man/pvdisplay.8_des
index 74d57ca78..68fe4a8b3 100644
--- a/man/pvdisplay.8_des
+++ b/man/pvdisplay.8_des
@@ -1,5 +1,5 @@
 pvdisplay shows the attributes of PVs, like size, physical extent size,
 space used for the VG descriptor area, etc.
-
+.P
 \fBpvs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
diff --git a/man/pvmove.8_des b/man/pvmove.8_des
index 0786f9ba8..d32a68bd1 100644
--- a/man/pvmove.8_des
+++ b/man/pvmove.8_des
@@ -3,13 +3,13 @@ more destination PVs.  You can optionally specify a source LV in which
 case only extents used by that LV will be moved to free (or specified)
 extents on the destination PV. If no destination PV is specified, the
 normal allocation rules for the VG are used.
-
+.P
 If pvmove is interrupted for any reason (e.g. the machine crashes) then
 run pvmove again without any PV arguments to restart any operations that
 were in progress from the last checkpoint. Alternatively, use the abort
 option at any time to abort the operation. The resulting location of LVs
 after an abort depends on whether the atomic option was used.
-
+.P
 More than one pvmove can run concurrently if they are moving data from
 different source PVs, but additional pvmoves will ignore any LVs already
 in the process of being changed, so some data might not get moved.
diff --git a/man/pvmove.8_end b/man/pvmove.8_end
index 8259b3f93..02f746b4b 100644
--- a/man/pvmove.8_end
+++ b/man/pvmove.8_end
@@ -1,9 +1,11 @@
+.
 .SH NOTES
+.
 pvmove works as follows:
-
+.P
 1. A temporary 'pvmove' LV is created to store details of all the data
 movements required.
-
+.P
 2. Every LV in the VG is searched for contiguous data that need moving
 according to the command line arguments.
 For each piece of data found, a new segment is added to the end of the
@@ -12,27 +14,27 @@ This segment takes the form of a temporary mirror to copy the data
 from the original location to a newly allocated location.
 The original LV is updated to use the new temporary mirror segment
 in the pvmove LV instead of accessing the data directly.
-
+.P
 3. The VG metadata is updated on disk.
-
+.P
 4. The first segment of the pvmove LV is activated and starts to mirror
 the first part of the data.  Only one segment is mirrored at once as this
 is usually more efficient.
-
+.P
 5. A daemon repeatedly checks progress at the specified time interval.
 When it detects that the first temporary mirror is in sync, it breaks that
 mirror so that only the new location for that data gets used and writes a
 checkpoint into the VG metadata on disk.  Then it activates the mirror for
 the next segment of the pvmove LV.
-
+.P
 6. When there are no more segments left to be mirrored, the temporary LV
 is removed and the VG metadata is updated so that the LVs reflect the new
 data locations.
-
+.P
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using
 \fBvgconvert\fP(8).
-
+.P
 If the \fB--atomic\fP option is used, a slightly different approach is
 used for the move.  Again, a temporary 'pvmove' LV is created to store the
 details of all the data movements required.  This temporary LV contains
@@ -43,48 +45,48 @@ temporary LV to the second.  After a complete copy is made, the temporary
 LVs are removed, leaving behind the segments on the destination PV.  If an
 abort is issued during the move, all LVs being moved will remain on the
 source PV.
-
+.
 .SH EXAMPLES
-
+.
 Move all physical extents that are used by simple LVs on the specified PV to
 free physical extents elsewhere in the VG.
 .br
 .B pvmove /dev/sdb1
-
+.P
 Use a specific destination PV when moving physical extents.
 .br
 .B pvmove /dev/sdb1 /dev/sdc1
-
+.P
 Move extents belonging to a single LV.
 .br
 .B pvmove -n lvol1 /dev/sdb1 /dev/sdc1
-
+.P
 Rather than moving the contents of an entire device, it is possible to
 move a range of physical extents, for example numbers 1000 to 1999
 inclusive on the specified PV.
 .br
 .B pvmove /dev/sdb1:1000-1999
-
+.P
 A range of physical extents to move can be specified as start+length. For
 example, starting from PE 1000. (Counting starts from 0, so this refers to the
 1001st to the 2000th PE inclusive.)
 .br
 .B pvmove /dev/sdb1:1000+1000
-
+.P
 Move a range of physical extents to a specific PV (which must have
 sufficient free extents).
 .br
 .B pvmove /dev/sdb1:1000-1999 /dev/sdc1
-
+.P
 Move a range of physical extents to specific new extents on a new PV.
 .br
 .B pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
-
+.P
 If the source and destination are on the same disk, the
 \fBanywhere\fP allocation policy is needed.
 .br
 .B pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
-
+.P
 The part of a specific LV present within in a range of physical
 extents can also be picked out and moved.
 .br
diff --git a/man/pvremove.8_des b/man/pvremove.8_des
index cc84148a1..01c75f1e8 100644
--- a/man/pvremove.8_des
+++ b/man/pvremove.8_des
@@ -1,7 +1,7 @@
 pvremove wipes the label on a device so that LVM will no longer recognise
 it as a PV.
-
+.P
 A PV cannot be removed from a VG while it is used by an active LV.
-
+.P
 Repeat the force option (\fB-ff\fP) to forcibly remove a PV belonging to
 an existing VG. Normally, \fBvgreduce\fP(8) should be used instead.
diff --git a/man/pvresize.8_end b/man/pvresize.8_end
index a347e4ad9..4831716cc 100644
--- a/man/pvresize.8_end
+++ b/man/pvresize.8_end
@@ -1,11 +1,15 @@
+.
 .SH NOTES
+.
 pvresize will refuse to shrink a PV if it has allocated extents beyond the
 new end.
+.
 .SH EXAMPLES
+.
 Expand a PV after enlarging the partition.
 .br
 .B pvresize /dev/sda1
-
+.P
 Shrink a PV prior to shrinking the partition (ensure that the PV size is
 appropriate for the intended new partition size).
 .br
diff --git a/man/pvs.8_end b/man/pvs.8_end
index c18f5518b..3ba3d391a 100644
--- a/man/pvs.8_end
+++ b/man/pvs.8_end
@@ -1,3 +1,4 @@
+.
 .SH NOTES
 .
 The pv_attr bits are:
diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index f685b8254..b20b987da 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -3,38 +3,38 @@ like
 .BR pvs (8)
 or
 .BR pvdisplay (8).
-
+.P
 When the --cache and -aay options are used, pvscan records which PVs are
 available on the system, and activates LVs in completed VGs.  A VG is
 complete when pvscan sees that the final PV in the VG has appeared.  This
 is used by event-based system startup (systemd, udev) to activate LVs.
-
+.P
 The four main variations of this are:
-
+.P
 .B pvscan --cache
-.IR device
-
+.I device
+.P
 If device is present, lvm adds a record that the PV on device is online.
 If device is not present, lvm removes the online record for the PV.
 In most cases, the pvscan will only read the named devices.
-
+.P
 .B pvscan --cache -aay
 .IR device ...
-
+.P
 This begins by performing the same steps as above.  Afterward, if the VG
 for the specified PV is complete, then pvscan will activate LVs in the VG
 (the same as vgchange -aay vgname would do.)
-
+.P
 .B pvscan --cache
-
+.P
 This first clears all existing PV online records, then scans all devices
 on the system, adding PV online records for any PVs that are found.
-
+.P
 .B pvscan --cache -aay
-
+.P
 This begins by performing the same steps as pvscan --cache.  Afterward, it
 activates LVs in any complete VGs.
-
+.P
 To prevent devices from being scanned by pvscan --cache, add them
 to
 .BR lvm.conf (5)
@@ -42,19 +42,18 @@ to
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-
+.P
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
 .BR lvm.conf (5)
 .B activation/auto_activation_volume_list
-
+.P
 For more information, see:
 .br
 .B lvmconfig --withcomments activation/auto_activation_volume_list
-
+.P
 To disable auto-activation, explicitly set this list to an empty list,
 i.e. auto_activation_volume_list = [ ].
-
+.P
 When this setting is undefined (e.g. commented), then all LVs are
 auto-activated.
-
diff --git a/man/vgcfgbackup.8_des b/man/vgcfgbackup.8_des
index f96fad3eb..801b506e4 100644
--- a/man/vgcfgbackup.8_des
+++ b/man/vgcfgbackup.8_des
@@ -2,15 +2,15 @@ vgcfgbackup creates back up files containing metadata of VGs.
 If no VGs are named, back up files are created for all VGs.
 See \fBvgcfgrestore\fP for information on using the back up
 files.
-
+.P
 In a default installation, each VG is backed up into a separate file
 bearing the name of the VG in the directory \fI#DEFAULT_BACKUP_DIR#\fP.
-
+.P
 To use an alternative back up file, use \fB-f\fP. In this case, when
 backing up multiple VGs, the file name is treated as a template, with %s
 replaced by the VG name.
-
+.P
 NB. This DOES NOT back up the data content of LVs.
-
+.P
 It may also be useful to regularly back up the files in
 \fI#DEFAULT_SYS_DIR#\fP.
diff --git a/man/vgcfgrestore.8_des b/man/vgcfgrestore.8_des
index b79e2efba..dbc9aee16 100644
--- a/man/vgcfgrestore.8_des
+++ b/man/vgcfgrestore.8_des
@@ -1,11 +1,11 @@
 vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
 specifed in back up file.
-
+.P
 A back up file can be specified with \fB--file\fP.  If no backup file is
 specified, the most recent one is used. Use \fB--list\fP for a list of
 the available back up and archive files of a VG.
-
+.P
 WARNING: When a VG contains thin pools, changes to thin metadata cannot be
 reverted, and data loss may occur if thin metadata has changed. The force
 option is required to restore in this case.
diff --git a/man/vgcfgrestore.8_end b/man/vgcfgrestore.8_end
index ffcb3eee0..04e18bdb8 100644
--- a/man/vgcfgrestore.8_end
+++ b/man/vgcfgrestore.8_end
@@ -1,5 +1,6 @@
+.
 .SH NOTES
-
+.
 To replace PVs, \fBvgdisplay --partial --verbose\fP will show the
 UUIDs and sizes of any PVs that are no longer present. If a PV in the VG
 is lost and you wish to substitute another of the same size, use
diff --git a/man/vgchange.8_end b/man/vgchange.8_end
index 828a70740..dd95d8103 100644
--- a/man/vgchange.8_end
+++ b/man/vgchange.8_end
@@ -1,12 +1,16 @@
+.
 .SH NOTES
+.
 If vgchange recognizes COW snapshot LVs that were dropped because they ran
 out of space, it displays a message informing the administrator that the
 snapshots should be removed.
+.
 .SH EXAMPLES
+.
 Activate all LVs in all VGs on all existing devices.
 .br
 .B vgchange -a y
-
+.P
 Change the maximum number of LVs for an inactive VG.
 .br
 .B vgchange -l 128 vg00
diff --git a/man/vgcreate.8_des b/man/vgcreate.8_des
index e2861c3a0..6e0d11bed 100644
--- a/man/vgcreate.8_des
+++ b/man/vgcreate.8_des
@@ -2,9 +2,8 @@ vgcreate creates a new VG on block devices. If the devices were not
 previously initialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
-
+.P
 When vgcreate uses an existing PV, that PV's existing values for metadata
 size, PE start, etc, are used, even if different values are specified in
 the vgcreate command.  To change these values, first use pvremove on the
 device.
-
diff --git a/man/vgcreate.8_end b/man/vgcreate.8_end
index e4c81e344..28b87febf 100644
--- a/man/vgcreate.8_end
+++ b/man/vgcreate.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Create a VG with two PVs, using the default physical extent size.
 .br
 .B vgcreate myvg /dev/sdk1 /dev/sdl1
diff --git a/man/vgdisplay.8_des b/man/vgdisplay.8_des
index c42f8218b..fa3d29a4f 100644
--- a/man/vgdisplay.8_des
+++ b/man/vgdisplay.8_des
@@ -1,4 +1,4 @@
 vgdisplay shows the attributes of VGs, and the associated PVs and LVs.
-
+.P
 \fBvgs\fP(8) is a preferred alternative that shows the same information
 and more, using a more compact and configurable output format.
diff --git a/man/vgexport.8_des b/man/vgexport.8_des
index 9f276afa7..0c6f4af9d 100644
--- a/man/vgexport.8_des
+++ b/man/vgexport.8_des
@@ -4,16 +4,16 @@ imported by \fBvgimport\fP(8).  Putting a VG into an unusable, offline
 state can be useful when doing things like moving a VG's disks to another
 system.  Exporting a VG provides some protection from its LVs being
 accidentally used, or being used by an automated system before it's ready.
-
+.P
 A VG cannot be exported until all of its LVs are inactive.
-
+.P
 LVM commands will ignore an exported VG or report an error if a command
 tries to use it.
-
+.P
 For an exported VG, the vgs command will display \"x\" in the third VG
 attribute, and the pvs command will display \"x\" in the second PV
 attribute.  Both vgs and pvs will display \"exported\" from the export
 report field.
-
+.P
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
diff --git a/man/vgextend.8_des b/man/vgextend.8_des
index cee2d1eb5..cf7c66129 100644
--- a/man/vgextend.8_des
+++ b/man/vgextend.8_des
@@ -1,10 +1,10 @@
 vgextend adds one or more PVs to a VG. This increases the space available
 for LVs in the VG.
-
+.P
 Also, PVs that have gone missing and then returned, e.g. due to a
 transient device failure, can be added back to the VG without
 re-initializing them (see --restoremissing).
-
+.P
 If the specified PVs have not yet been initialized with pvcreate, vgextend
 will initialize them. In this case pvcreate options can be used, e.g.
 --labelsector, --metadatasize, --metadataignore,
diff --git a/man/vgextend.8_end b/man/vgextend.8_end
index 7cd8fd602..e63fa1343 100644
--- a/man/vgextend.8_end
+++ b/man/vgextend.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Add two PVs to a VG.
 .br
 .B vgextend vg00 /dev/sda4 /dev/sdn1
diff --git a/man/vgimport.8_des b/man/vgimport.8_des
index 91196b683..22d36ce9a 100644
--- a/man/vgimport.8_des
+++ b/man/vgimport.8_des
@@ -1,5 +1,5 @@
 vgimport makes exported VGs known to the system again, perhaps after
 moving the PVs from a different system.
-
+.P
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
diff --git a/man/vgimportclone.8_des b/man/vgimportclone.8_des
index a5002da6d..e5d13433c 100644
--- a/man/vgimportclone.8_des
+++ b/man/vgimportclone.8_des
@@ -1,6 +1,6 @@
 vgimportclone imports a VG from duplicated PVs, e.g. created by a hardware
 snapshot of existing PVs.
-
+.P
 A duplicated VG cannot used until it is made to coexist with the original
 VG. vgimportclone renames the VG associated with the specified PVs and
 changes the associated VG and PV UUIDs.
diff --git a/man/vgimportclone.8_end b/man/vgimportclone.8_end
index 68c57d44f..4a092974e 100644
--- a/man/vgimportclone.8_end
+++ b/man/vgimportclone.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 An original VG "vg00" has PVs "/dev/sda" and "/dev/sdb".
 The corresponding PVs from a hardware snapshot are "/dev/sdc" and "/dev/sdd".
 Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_snap"
diff --git a/man/vgimportdevices.8_des b/man/vgimportdevices.8_des
index 7c2287cfd..8ad3836e1 100644
--- a/man/vgimportdevices.8_des
+++ b/man/vgimportdevices.8_des
@@ -3,9 +3,8 @@ to using using lvmdevices --adddev to add each PV to the devices file
 individually.  vgimportdevices will also update the VG metadata to include
 the device IDs of each PV.  vgimportdevices will create a new devices file
 if none exists.
-
+.P
 When a devices file is used, the regex filter is ignored, except in the case
 of vgimportdevices which will apply the regex filter when looking for the VGs
 to import to the devices file.  Use vgimportdevices -a to import all VGs on a
 system to the devices file.
-
diff --git a/man/vgmerge.8_end b/man/vgmerge.8_end
index 905492dc4..c64190d86 100644
--- a/man/vgmerge.8_end
+++ b/man/vgmerge.8_end
@@ -1,5 +1,6 @@
+.
 .SH EXAMPLES
-
+.
 Merge an inactive VG named "vg00" into the active or inactive VG named
 "databases", giving verbose runtime information.
 .br
diff --git a/man/vgmknodes.8_des b/man/vgmknodes.8_des
index a93d629e1..14c117734 100644
--- a/man/vgmknodes.8_des
+++ b/man/vgmknodes.8_des
@@ -1,5 +1,5 @@
 vgmknodes checks the LVM device nodes in /dev that are needed for active
 LVs and creates any that are missing and removes unused ones.
-
+.P
 This command should not usually be needed if all the system components are
 interoperating correctly.
diff --git a/man/vgremove.8_des b/man/vgremove.8_des
index e87666fd6..3b1c23821 100644
--- a/man/vgremove.8_des
+++ b/man/vgremove.8_des
@@ -1,9 +1,9 @@
 vgremove removes one or more VGs. If LVs exist in the VG, a prompt is used
 to confirm LV removal.
-
+.P
 If one or more PVs in the VG are lost, consider
 \fBvgreduce --removemissing\fP to make the VG
 metadata consistent again.
-
+.P
 Repeat the force option (\fB-ff\fP) to forcibly remove LVs in the VG
 without confirmation.
diff --git a/man/vgrename.8_des b/man/vgrename.8_des
index 2384b6bf0..7c9802b42 100644
--- a/man/vgrename.8_des
+++ b/man/vgrename.8_des
@@ -1,5 +1,5 @@
 vgrename renames a VG.
-
+.P
 All VGs visible to a system need to have different names, otherwise many
 LVM commands will refuse to run or give warning messages. VGs with the
 same name can occur when disks are moved between machines, or filters are
diff --git a/man/vgrename.8_end b/man/vgrename.8_end
index 5cdd0d02e..f66b764a8 100644
--- a/man/vgrename.8_end
+++ b/man/vgrename.8_end
@@ -1,9 +1,10 @@
+.
 .SH EXAMPLES
-
+.
 Rename VG "vg02" to "myvg":
 .br
 .B vgrename "vg02" "myvg"
-
+.P
 Rename the VG with the specified UUID to "myvg".
 .br
 .B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 myvg
diff --git a/man/vgs.8_end b/man/vgs.8_end
index 06699187c..19727fabf 100644
--- a/man/vgs.8_end
+++ b/man/vgs.8_end
@@ -1,3 +1,4 @@
+.
 .SH NOTES
 .
 The vg_attr bits are:
diff --git a/man/vgsplit.8_des b/man/vgsplit.8_des
index d42ff1628..8eb5753d7 100644
--- a/man/vgsplit.8_des
+++ b/man/vgsplit.8_des
@@ -2,13 +2,13 @@ vgsplit moves one or more PVs from a source VG (the first VG arg) to a
 destination VG (the second VG arg).  The PV(s) to move are named after the
 source and destination VGs, or an LV is named, in which case the PVs
 underlying the LV are moved.
-
+.P
 If the destination VG does not exist, a new VG is created (command options
 can be used to specify properties of the new VG, also see
-\fBvgcreate\fP(8).)
-
+\fBvgcreate\fP(8)).
+.P
 LVs cannot be split between VGs; each LV must be entirely on the PVs in
 the source or destination VG.
-
+.P
 vgsplit can only move complete PVs. (See \fBpvmove\fP(8) for moving part
 of a PV.)


