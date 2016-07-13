From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Jul 2016 18:13:27 +0000 (UTC)
Subject: master - man: changes to lvconvert
Message-ID: <20160713181327.0F437609CB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26f3b321f92f49fe20749cb09727f0908867b534
Commit:        26f3b321f92f49fe20749cb09727f0908867b534
Parent:        df5021a2017e395c68d1bee012a54a1d59c63c90
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 13 13:09:38 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 13 13:13:05 2016 -0500

man: changes to lvconvert

Generally include more information about options.
---
 man/lvconvert.8.in |  270 +++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 225 insertions(+), 45 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index f51ad61..5f15f34 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -8,19 +8,168 @@ lvconvert \(em change LV type and other utilities
 .RI [ OPTION ]...
 .IR VolumeGroup / LogicalVolume
 
+OPTIONS:
+.br
+.BR \-b ,
+.BR \-\-background
+.br
+.BR \-\-cachepolicy
+.IR Policy
+.br
+.BR \-\-cachepool
+.IR CachePoolLogicalVolume { Name | Path }
+.br
+.BR \-\-cachesettings
+.IB Key = Value
+.br
+.BR \-c ,
+.BR \-\-chunksize
+.BR \fIChunkSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
+.BR \-\-corelog
+.br
+.BR \-\-discards
+.RB { ignore | nopassdown | passdown }
+.br
+.BR \-i ,
+.BR \-\-interval
+.IR Seconds
+.br
+.BR \-\-merge
+.br
+.BR \-\-mirrorlog
+.RB { disk | core | mirrored }
+.br
+.BR \-m ,
+.BR \-\-mirrors
+.IR Number
+.br
+.BR \-n ,
+.BR \-\-name
+.IR Name
+.br
+.BR \-\-noudevsync
+.br
+.BR \-\-originname
+.IR NewExternalOriginVolumeName
+.br
+.BR \-\-poolmetadata
+.IR PoolMetadataLogicalVolume { Name | Path }
+.br
+.BR \-\-poolmetadatasize
+.BR \fIPoolMetadataSize [ b | B | s | S | k | K | m | M | g | G ]
+.br
+.BR \-\-poolmetadataspare
+.RB { y | n }
+.br
+.BR \-r ,
+.BR \-\-readahead
+.RB { \fIReadAheadSectors | auto | none }
+.br
+.BR \-R ,
+.BR \-\-regionsize
+.IR MirrorLogRegionSize
+.br
+.BR \-\-repair
+.br
+.BR \-\-replace
+.IR PhysicalVolume
+.br
+.BR \-\-splitcache
+.br
+.BR \-\-splitmirrors
+.IR Number
+.br
+.BR \-\-splitsnapshot
+.br
+.BR \-\-stripes
+.IR Number
+.br
+.BR \-I ,
+.BR \-\-stripesize
+.IR StripeSize
+.br
+.B \-\-type striped
+.br
+.B \-\-type snapshot
+.R |
+.B \-\-snapshot
+.R |
+.B \-s
+.br
+.B \-\-type mirror
+.br
+.B \-\-type raid*
+.br
+.B \-\-type thin
+.R |
+.B \-\-thin
+.R |
+.B \-T
+.br
+.B \-\-type cache
+.R |
+.B \-\-cache
+.R |
+.B \-H
+.br
+.B \-\-type thin\-pool
+.br
+.B \-\-type cache\-pool
+.br
+.BR \-\-thinpool
+.IR ThinPoolLogicalVolume { Name | Path }
+.br
+.BR \-\-trackchanges
+.br
+.BR \-\-uncache
+.br
+.BR \-Z ,
+.BR \-\-zero
+.RB { y | n }
+.br
+
+Common options:
+.br
+.BR \-A ,
+.BR \-\-alloc
+.IR AllocationPolicy
+.br
+.BR \-f ,
+.BR \-\-force
+.br
+.BR \-\-commandprofile
+.IR ProfileName
+.br
+.BR \-h ,
+.BR \-? ,
+.BR \-\-help
+.br
+.BR \-v ,
+.BR \-\-verbose
+.br
+.BR \-y ,
+.BR \-\-yes
+.br
+.BR \-\-version
+
+
+
+
 .SH DESCRIPTION
 
 lvconvert changes the LV type and includes various LV utilities.
 
 To display the current LV type, run the command:
 
-.B lvs \-o name,segtype VG/LV
+.B lvs \-o name,segtype
+.IR VG / LV
 
 To change the LV type, run the command:
 
 .B lvconvert \-\-type
 .I NewType
-.B VG/LV
+.IR VG / LV
 
 .SS LV types
 
@@ -93,10 +242,10 @@ VG/StripedLV
 Merge StripedLV into an LV when it is a previously split mirror.
 .br
 \[bu]
-See corresponding operation --splitmirrors.
+Options \-\-background, \-\-interval.
 .br
 \[bu]
-Also see \-\-background, \-\-interval.
+See corresponding operation --splitmirrors.
 
 .B lvconvert \-\-type snapshot
 VG/StripedLV VG/SnapshotLV
@@ -105,6 +254,9 @@ VG/StripedLV VG/SnapshotLV
 Recombine StripedLV with SnapshotLV which was previously split.
 .br
 \[bu]
+Options \-\-chunksize, \-\-zero.
+.br
+\[bu]
 See corresponding operation --splitsnapshot.
 
 .B lvconvert \-\-type thin
@@ -114,13 +266,13 @@ VG/StripedLV
 Convert StripedLV to type thin with an external origin.
 .br
 \[bu]
-Requires \-\-thinpool to specify the thin pool to use.
+StripedLV becomes a read\-only external origin LV with a new name.
 .br
 \[bu]
-StripedLV becomes a read\-only external origin LV with a new name.
+Requires \-\-thinpool to specify the thin pool to use.
 .br
 \[bu]
-Also see \-\-originname.
+Options \-\-originname.
 
 .B lvconvert \-\-type cache
 VG/StripedLV
@@ -132,7 +284,7 @@ Convert StripedLV to type cache.
 Requires \-\-cachepool to specify the cache pool to use.
 .br
 \[bu]
-Also see \-\-cachepolicy, \-\-cachesettings.
+Options \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-type thin\-pool
 VG/StripedLV
@@ -141,7 +293,12 @@ VG/StripedLV
 Convert StripedLV to type thin\-pool.
 .br
 \[bu]
-Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
+The StripedLV is used for thin pool data.
+.br
+\[bu]
+Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
+.br
+  \-\-readahead, \-\-zero.
 
 .B lvconvert \-\-type cache\-pool
 VG/StripedLV
@@ -150,7 +307,7 @@ VG/StripedLV
 Convert StripedLV to type cache\-pool.
 .br
 \[bu]
-Also see \-\-chunksize, \-\-poolmetadata{size}.
+Options \-\-chunksize, \-\-poolmetadata{size,spare}.
 
 .B lvconvert \-\-type mirror
 VG/StripedLV
@@ -160,6 +317,9 @@ Convert StripedLV to type mirror.
 .br
 \[bu]
 Requires \-\-mirrors to specify the number of mirrors to use.
+.br
+\[bu]
+Options \-\-mirrorlog, \-\-regionsize.
 
 .B lvconvert \-\-type raid*
 VG/StripedLV
@@ -199,10 +359,10 @@ VG/RaidLV
 Merge RaidLV into an LV when it is a previously split mirror.
 .br
 \[bu]
-See corresponding operation --splitmirrors.
+Options \-\-background, \-\-interval.
 .br
 \[bu]
-Also see \-\-background, \-\-interval.
+See corresponding operation --splitmirrors.
 
 .B lvconvert \-\-repair
 VG/RaidLV
@@ -218,7 +378,7 @@ VG/RaidLV
 Replace specific PV(s) in a raid* LV with another PV.
 .br
 \[bu]
-The replacement PV can be optionally specified, see below.
+The new PV(s) to use can be optionally specified after the LV.
 .br
 \[bu]
 Repeat to replace multiple: \-\-replace PV1 \-\-replace PV2 ...
@@ -231,6 +391,9 @@ VG/SnapshotLV
 Combine RaidLV with SnapshotLV that was previously split.
 .br
 \[bu]
+Options \-\-chunksize, \-\-zero.
+.br
+\[bu]
 See corresponding operation \-\-splitsnapshot.
 
 .B lvconvert \-\-type thin
@@ -240,13 +403,13 @@ VG/RaidLV
 Convert RaidLV to type thin with an external origin.
 .br
 \[bu]
-Requires \-\-thinpool to specify the thin pool to use.
+RaidLV becomes a read\-only external origin LV with a new name.
 .br
 \[bu]
-RaidLV becomes a read\-only external origin LV with a new name.
+Requires \-\-thinpool to specify the thin pool to use.
 .br
 \[bu]
-Also see \-\-originname.
+Options \-\-originname.
 
 .B lvconvert \-\-type cache
 VG/RaidLV
@@ -258,7 +421,7 @@ Convert RaidLV to type cache.
 Requires \-\-cachepool to specify the cache pool to use.
 .br
 \[bu]
-Also see \-\-cachepolicy, \-\-cachesettings.
+Options \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-type thin\-pool
 VG/RaidLV
@@ -267,7 +430,12 @@ VG/RaidLV
 Convert RaidLV to type thin\-pool.
 .br
 \[bu]
-Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
+The RaidLV is used for thin pool data.
+.br
+\[bu]
+Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
+.br
+  \-\-readahead, \-\-zero.
 
 .B lvconvert \-\-type cache\-pool
 VG/RaidLV
@@ -276,7 +444,7 @@ VG/RaidLV
 Convert RaidLV to type cache\-pool.
 .br
 \[bu]
-Also see \-\-chunksize, \-\-poolmetadata{size}.
+Options \-\-chunksize, \-\-poolmetadata{size,spare}.
 
 .B lvconvert \-\-type raid*
 VG/RaidLV
@@ -400,7 +568,9 @@ Convert CacheLV to type thin-pool.
 The CacheLV is used for thin pool data.
 .br
 \[bu]
-Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
+Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
+.br
+  \-\-readahead, \-\-zero.
 
 
 .SS Operations on ThinPoolLV with type thin\-pool:
@@ -441,7 +611,7 @@ Convert the data portion of ThinPoolLV to type cache.
 Operates on the data sub LV of the thin pool LV.
 .br
 \[bu]
-Also see \-\-cachepolicy, \-\-cachesettings.
+Options \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-repair
 VG/ThinPoolLV
@@ -464,7 +634,7 @@ Merge ThinLV into its origin LV.
 ThinLV must have been created as a snapshot of another thin LV.
 .br
 \[bu]
-Also see \-\-background, \-\-interval.
+Options \-\-background, \-\-interval.
 
 .SS Operations on SnapshotLV with type snapshot:
 
@@ -484,7 +654,7 @@ VG/SnapshotLV
 Merge COW snapshot SnapshotLV into its origin.
 .br
 \[bu]
-Also see \-\-background, \-\-interval.
+Options \-\-background, \-\-interval.
 
 .SH OPTIONS
 .
@@ -568,6 +738,16 @@ Also see
 .BR lvmthin (7).
 .
 .HP
+.BR \-H ,
+.BR \-\-cache
+.br
+Alias for
+.B \-\-type cache.
+See COMMANDS description for
+.br
+.B lvconvert \-\-type cache.
+.
+.HP
 .BR \-i ,
 .BR \-\-interval
 .IR Seconds
@@ -763,6 +943,15 @@ for specific limits on device replacement for each raid level.
 (This option only applies to \fBraid*\fP LV types.)
 .
 .HP
+.BR \-s ,
+.BR \-\-snapshot
+.br
+Alias for
+.B \-\-type snapshot.
+See COMMANDS description for
+.br
+.B lvconvert \-\-type snapshot.
+.HP
 .BR \-\-split
 .br
 Separates \fISplitableLogicalVolume\fP.
@@ -827,7 +1016,8 @@ and cannot exceed the VG physical extent (PE) size.
 .BR \-\-type
 .IR SegmentType
 .br
-Converts an LV from one segment type to another.  See commmands above.
+Converts an LV from one segment type to another.
+See COMMANDS section for a description of converting between each type.
 .
 .HP
 .BR \-\-thinpool
@@ -850,6 +1040,16 @@ changed data are resynchronized during merge.  (This option only applies
 to the \fBraid1\fP LV type.)
 .
 .HP
+.BR \-T ,
+.BR \-\-thin
+.br
+Alias for
+.B \-\-type thin.
+See COMMANDS description for
+.br
+.B lvconvert \-\-type thin.
+.
+.HP
 .BR \-\-uncache
 .br
 Separates a cache pool from a cache LV, and removes the unused cache pool
@@ -872,26 +1072,6 @@ Also see
 .BR lvmthin (7).
 .
 
-.SS Option aliases
-
-.B \-\-type cache
-can be replaced with
-.B \-H
-or
-.B \-\-cache.
-
-.B \-\-type thin
-can be replaced with
-.B \-T
-or
-.B \-\-thin.
-
-.B \-\-type snapshot
-can be replaced with
-.B \-s
-or
-.B \-\-snapshot.
-
 .SH Examples
 .
 Convert a linear LV to a two-way mirror LV:
@@ -980,7 +1160,7 @@ metadata:
 
 Convert an LV to a cache LV using the specified cache pool and chunk size:
 .br
-.B lvconvert \-\-cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
+.B lvconvert \-\-type cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
 
 Detach and keep the cache pool from a cache LV:
 .br


