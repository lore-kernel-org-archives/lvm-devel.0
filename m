From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 11 Jul 2016 15:30:18 +0000 (UTC)
Subject: master - man: lvconvert changes
Message-ID: <20160711153018.8B3FD605F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c526c327d7352e60eb19a739a2f394e2744c5629
Commit:        c526c327d7352e60eb19a739a2f394e2744c5629
Parent:        06a9dab730f5b1636c19ffd47124d76e60447efd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 8 15:22:31 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 11 10:29:07 2016 -0500

man: lvconvert changes

---
 man/lvconvert.8.in |  110 +++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 79 insertions(+), 31 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index e85fe96..f51ad61 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -87,13 +87,16 @@ avoid the direct use of hidden LVs.
 
 .B lvconvert \-\-merge
 VG/StripedLV
+./" FIXME: use --merge-mirror
 .br
 \[bu]
 Merge StripedLV into an LV when it is a previously split mirror.
 .br
 \[bu]
-See --splitmirror.
-./" FIXME: use --merge-mirror
+See corresponding operation --splitmirrors.
+.br
+\[bu]
+Also see \-\-background, \-\-interval.
 
 .B lvconvert \-\-type snapshot
 VG/StripedLV VG/SnapshotLV
@@ -102,7 +105,7 @@ VG/StripedLV VG/SnapshotLV
 Recombine StripedLV with SnapshotLV which was previously split.
 .br
 \[bu]
-See --splitsnapshot.
+See corresponding operation --splitsnapshot.
 
 .B lvconvert \-\-type thin
 VG/StripedLV
@@ -111,13 +114,13 @@ VG/StripedLV
 Convert StripedLV to type thin with an external origin.
 .br
 \[bu]
-Also specify a thin pool to use, see \-\-thinpool.
+Requires \-\-thinpool to specify the thin pool to use.
 .br
 \[bu]
 StripedLV becomes a read\-only external origin LV with a new name.
 .br
 \[bu]
-See \-\-originname.
+Also see \-\-originname.
 
 .B lvconvert \-\-type cache
 VG/StripedLV
@@ -126,19 +129,28 @@ VG/StripedLV
 Convert StripedLV to type cache.
 .br
 \[bu]
-Also specify a cache pool to use, see \-\-cachepool.
+Requires \-\-cachepool to specify the cache pool to use.
+.br
+\[bu]
+Also see \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-type thin\-pool
 VG/StripedLV
 .br
 \[bu]
 Convert StripedLV to type thin\-pool.
+.br
+\[bu]
+Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
 
 .B lvconvert \-\-type cache\-pool
 VG/StripedLV
 .br
 \[bu]
 Convert StripedLV to type cache\-pool.
+.br
+\[bu]
+Also see \-\-chunksize, \-\-poolmetadata{size}.
 
 .B lvconvert \-\-type mirror
 VG/StripedLV
@@ -147,7 +159,7 @@ VG/StripedLV
 Convert StripedLV to type mirror.
 .br
 \[bu]
-Also specify the number of mirrors, see \-\-mirrors.
+Requires \-\-mirrors to specify the number of mirrors to use.
 
 .B lvconvert \-\-type raid*
 VG/StripedLV
@@ -156,7 +168,7 @@ VG/StripedLV
 Convert StripedLV to type raid*.
 .br
 \[bu]
-Also specify the number of mirrors, see \-\-mirrors.
+Required options depend on the raid level, see lvmraid(7).
 
 .SS Operations on RaidLV with type raid*:
 
@@ -177,17 +189,20 @@ VG/RaidLV
 Split images from raid1 RaidLV and use them to create a new LV.
 .br
 \[bu]
-Also specify \-\-name for new LV, or use \-\-trackchanges.
+Requires \-\-name for the new LV, or the use of \-\-trackchanges.
 
 .B lvconvert \-\-merge
 VG/RaidLV
+./" FIXME: use --merge-mirror
 .br
 \[bu]
 Merge RaidLV into an LV when it is a previously split mirror.
 .br
 \[bu]
-See --splitmirror.
-./" FIXME: use --merge-mirror
+See corresponding operation --splitmirrors.
+.br
+\[bu]
+Also see \-\-background, \-\-interval.
 
 .B lvconvert \-\-repair
 VG/RaidLV
@@ -216,7 +231,7 @@ VG/SnapshotLV
 Combine RaidLV with SnapshotLV that was previously split.
 .br
 \[bu]
-See \-\-splitsnapshot.
+See corresponding operation \-\-splitsnapshot.
 
 .B lvconvert \-\-type thin
 VG/RaidLV
@@ -225,13 +240,13 @@ VG/RaidLV
 Convert RaidLV to type thin with an external origin.
 .br
 \[bu]
-Also specify a thin pool to use, see \-\-thinpool.
+Requires \-\-thinpool to specify the thin pool to use.
 .br
 \[bu]
 RaidLV becomes a read\-only external origin LV with a new name.
 .br
 \[bu]
-See \-\-originname.
+Also see \-\-originname.
 
 .B lvconvert \-\-type cache
 VG/RaidLV
@@ -240,25 +255,37 @@ VG/RaidLV
 Convert RaidLV to type cache.
 .br
 \[bu]
-Also specify a cache pool to use, see \-\-cachepool.
+Requires \-\-cachepool to specify the cache pool to use.
+.br
+\[bu]
+Also see \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-type thin\-pool
 VG/RaidLV
 .br
 \[bu]
 Convert RaidLV to type thin\-pool.
+.br
+\[bu]
+Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
 
 .B lvconvert \-\-type cache\-pool
 VG/RaidLV
 .br
 \[bu]
 Convert RaidLV to type cache\-pool.
+.br
+\[bu]
+Also see \-\-chunksize, \-\-poolmetadata{size}.
 
 .B lvconvert \-\-type raid*
 VG/RaidLV
 .br
 \[bu]
 Convert RaidLV to use a different raid level.
+.br
+\[bu]
+Required options depend on the raid level, see lvmraid(7).
 
 .B lvconvert \-\-type striped
 VG/RaidLV
@@ -291,7 +318,7 @@ VG/MirrorLV
 Split images from MirrorLV and use them to create a new LV.
 .br
 \[bu]
-Also specify \-\-name for new LV.
+Requires \-\-name for the new LV.
 
 .B lvconvert \-\-mirrorlog
 LogType
@@ -299,9 +326,6 @@ VG/MirrorLV
 .br
 \[bu]
 Change the type of log used by MirrorLV.
-.br
-\[bu]
-See --mirrorlog and --corelog for log types.
 
 .B lvconvert \-\-repair
 VG/MirrorLV
@@ -322,7 +346,7 @@ VG/MirrorLV
 Convert MirrorLV to type raid*.
 .br
 \[bu]
-See lvmraid(7) for permitted raid levels.
+Required options depend on the raid level, see lvmraid(7).
 
 .SS Operations on CachePoolLV with type cache\-pool:
 
@@ -364,7 +388,7 @@ Split images from the mirrored origin of CacheLV to create a new LV.
 Operates on mirror or raid1 sub LV.
 .br
 \[bu]
-Also specify \-\-name for new LV, or use \-\-trackchanges.
+Requires \-\-name for the new LV, or the use of \-\-trackchanges.
 
 .B lvconvert \-\-type thin\-pool
 VG/CacheLV
@@ -374,6 +398,9 @@ Convert CacheLV to type thin-pool.
 .br
 \[bu]
 The CacheLV is used for thin pool data.
+.br
+\[bu]
+Also see \-\-chunksize, \-\-discards, \-\-zero, \-\-poolmetadata{size}.
 
 
 .SS Operations on ThinPoolLV with type thin\-pool:
@@ -412,6 +439,9 @@ Convert the data portion of ThinPoolLV to type cache.
 .br
 \[bu]
 Operates on the data sub LV of the thin pool LV.
+.br
+\[bu]
+Also see \-\-cachepolicy, \-\-cachesettings.
 
 .B lvconvert \-\-repair
 VG/ThinPoolLV
@@ -425,13 +455,16 @@ Repair ThinPoolLV.
 
 .B lvconvert \-\-merge
 VG/ThinLV
+./" FIXME: use --merge-snapshot
 .br
 \[bu]
 Merge ThinLV into its origin LV.
 .br
 \[bu]
 ThinLV must have been created as a snapshot of another thin LV.
-./" FIXME: use --merge-snapshot
+.br
+\[bu]
+Also see \-\-background, \-\-interval.
 
 .SS Operations on SnapshotLV with type snapshot:
 
@@ -445,10 +478,13 @@ Separate COW snapshot SnapshotLV from its origin LV.
 
 .B lvconvert \-\-merge
 VG/SnapshotLV
+./" FIXME: use --merge-snapshot
 .br
 \[bu]
 Merge COW snapshot SnapshotLV into its origin.
-./" FIXME: use --merge-snapshot
+.br
+\[bu]
+Also see \-\-background, \-\-interval.
 
 .SH OPTIONS
 .
@@ -528,6 +564,8 @@ It is an alias for \fB\-\-mirrorlog core\fP.
 Specifies if discards will be processed by the thin layer in the
 kernel and passed down to the Physical Volume.  This applies only
 to thin pools.  The default is \fBpassdown\fP.
+Also see
+.BR lvmthin (7).
 .
 .HP
 .BR \-i ,
@@ -700,6 +738,8 @@ Use \fB\-f\fP if you do not want any replacement.  You may use
 \fB\-\-use\-policies\fP to use the device replacement policy specified in
 \fBlvm.conf\fP(5), see \fBactivation/mirror_log_fault_policy\fP or
 \fBactivation/mirror_device_fault_policy\fP.
+Also see
+.BR lvmraid (7).
 
 When used with a thin pool LV, this option automates the use of the
 \fBthin_repair\fP(8) tool on the thin pool.  This repairs a very limitted
@@ -707,6 +747,8 @@ number of problems.  Only inactive thin pools can be repaired.  There is
 no validation of metadata between kernel and LVM.  This requires further
 manual work.  After successfull repair the old unmodified metadata are
 still available in "<pool>_meta<n>" LV.
+Also see
+.BR lvmthin (7).
 .
 .HP
 .BR \-\-replace
@@ -726,14 +768,16 @@ for specific limits on device replacement for each raid level.
 Separates \fISplitableLogicalVolume\fP.
 This option tries to detect the necessary split operation from its arguments.
 Avoid using this option and use one of the following instead:
-.B \-\-splitcache, \-\-splitmirror, \-\-splitsnapshot.
+.B \-\-splitcache, \-\-splitmirrors, \-\-splitsnapshot.
 .
 .HP
 .BR \-\-splitcache
 .br
 Separates a cache pool from a cache LV, and keeps the unused cache pool
-LV.  Before the separation, the cache is flushed.  Also see
+LV.  Before the separation, the cache is flushed.  See similar option
 .B \-\-uncache.
+Also see
+.BR lvmcache (7).
 .
 .HP
 .BR \-\-splitmirrors
@@ -756,7 +800,7 @@ required without \fB\-\-trackchanges\fP).
 Separates a COW snapshot from its origin LV.  The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
 describing them.  This LV can be wiped and then destroyed with lvremove.
-Also see
+See corresponding operation
 .B lvconvert \-\-type snapshot.
 .
 .HP
@@ -764,10 +808,10 @@ Also see
 .IR Number
 .br
 Specifies the number of stripes in a striped LV.  This is the number of
-physical volumes (devices) a striped LV is spread across.  Data that
-appears sequential in the LV is spread (striped) across multiple devices
-in units of the stripe size (see below).  This does not apply to existing
-allocated space, only newly allocated space can be striped.
+physical volumes (devices) that a striped LV is spread across.  Data that
+appears sequential in the LV is spread across multiple devices in units of
+the stripe size (see \fB\-\-stripesize\fP).  This does not apply to
+existing allocated space, only newly allocated space can be striped.
 .
 .HP
 .BR \-I ,
@@ -809,8 +853,10 @@ to the \fBraid1\fP LV type.)
 .BR \-\-uncache
 .br
 Separates a cache pool from a cache LV, and removes the unused cache pool
-LV.  Before the separation, the cache is flushed.  Also see
+LV.  Before the separation, the cache is flushed.  See similar option
 .B \-\-splitcache.
+Also see
+.BR lvmcache (7).
 .
 .HP
 .BR \-Z ,
@@ -822,6 +868,8 @@ snapshot.  If the LV is read\-only, the snapshot will not be zeroed.
 
 For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
+Also see
+.BR lvmthin (7).
 .
 
 .SS Option aliases


