From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Mar 2014 13:11:56 +0000 (UTC)
Subject: master - man: colorization fixes
Message-ID: <20140326131156.64A6D60FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dae455f806dfba878e9cfb766f7415ad038d72fe
Commit:        dae455f806dfba878e9cfb766f7415ad038d72fe
Parent:        bda0fe95ad66b864429ce18bb9dc6277259ba348
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 14:04:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 14:11:37 2014 +0100

man: colorization fixes

Fix style
---
 man/lvchange.8.in  |    6 +++---
 man/lvconvert.8.in |   22 +++++++++++-----------
 man/lvcreate.8.in  |    8 ++++----
 man/lvmetad.8.in   |   11 ++++-------
 4 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 64231c8..5de75e0 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -41,7 +41,7 @@ lvchange \- change attributes of a logical volume
 .RB [ \-\-[raid]writebehind
 .IR IOCount ]
 .RB [ \-\-[raid]writemostly
-.IR PhysicalVolume[:{t|n|y}] ]
+.IR PhysicalVolume [ : { t | n | y }]]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-M | \-\-persistent
@@ -166,7 +166,7 @@ If \fIrepair\fP is used, the discrepancies will be corrected as they are
 encountered.  The 'lvs' command can be used to show the number of
 discrepancies found or repaired.
 .TP
-.BR \-\-[raid]writebehind " IOCount"
+.BR \-\-[raid]writebehind " " \fIIOCount
 Specify the maximum number of outstanding writes that are allowed to
 devices in a RAID1 logical volume that are marked as \fIwrite-mostly\fP.
 Once this value is exceeded, writes become synchronous (i.e. all writes
@@ -174,7 +174,7 @@ to the constituent devices must complete before the array signals the
 write has completed).  Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
 .TP
-.BR \-\-[raid]writemostly " PhysicalVolume[:{t|y|n}]"
+.IR \fB\-\-[raid]writemostly " " PhysicalVolume [ : { t | y | n }]
 Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
 to these drives will be avoided unless absolutely necessary.  This keeps
 the number of I/Os to the drive to a minimum.  The default behavior is to
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index ade106d..fe6525b 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -91,11 +91,11 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
-.RB [[ \-\-poolmetadata
-.IR ThinPoolMetadataLogicalVolume { Name | Path }]
+.RB [{ \-\-poolmetadata
+.IR ThinPoolMetadataLogicalVolume { Name | Path }
 |
-.RB [ \-\-poolmetadatasize
-.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]
+.B \-\-poolmetadatasize
+.IR ThinPoolMetadataSize [ bBsSkKmMgG ]}]
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-stripes
@@ -113,24 +113,24 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .sp
-.B lvconvert \-\-type cache-pool
+.B lvconvert \-\-type \fIcache-pool
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
 .RI { writeback | writethrough }]
-.RB [[ \-\-poolmetadata
-.IR CachePoolMetadataLogicalVolume { Name | Path }]
+.RB [{ \-\-poolmetadata
+.IR CachePoolMetadataLogicalVolume { Name | Path }
 |
-.RB [ \-\-poolmetadatasize
-.IR CachePoolMetadataSize [ bBsSkKmMgG ]]
+.B \-\-poolmetadatasize
+.IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
 .IR LogicalVolume [ Path ]
 .RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .sp
-.B lvconvert \-\-type cache
-.RB \-\-cachepool
+.B lvconvert \-\-type \fIcache
+.B \-\-cachepool
 .IR CachePoolLV { Name | Path }
 .IR LogicalVolume [ Path ]
 .RB [ \-h | \-? | \-\-help ]
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 325baad..445af80 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -60,7 +60,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-t | \-\-test ]
 .RB [ \-T | \-\-thin
 .RB [ \-\-cachemode
-.IR { writeback | writethrough }
+.RI { writeback | writethrough }
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
@@ -145,7 +145,7 @@ be overridden. If the clustered locking is enabled,
 .IR \fB\-a { a | l } y
 will activate only on the local node.
 .TP
-.IR \fB\-k ", " \fB\-\-setactivationskip " " { y | n }
+.IR \fB\-k ", " \fB\-\-setactivationskip "  {" y | n }
 Controls whether Logical Volumes are persistently flagged to be skipped during
 activation. By default, thin snapshot volumes are flagged for activation skip.
 To activate such volumes, an extra \fB\-K/\-\-ignoreactivationskip\fP option must
@@ -155,11 +155,11 @@ detach the flag for existing volumes. To see whether the flag is attached,
 use \fBlvs\fP command where the state of the flag is reported within
 \fBlv_attr\fP bits.
 .TP
-.IR \fB\-K ", " \fB\-\-ignoreactivationskip
+.BR \-K ", " \-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
 
 .TP
-.BR \-\-cachemode " " { writeback | writethrough }
+.IR \fB\-\-cachemode " " { writeback | writethrough }
 Specifying a cache mode determines when the writes to a cache LV
 are considered complete.  When \fIwriteback\fP is specified, a write is
 considered complete as soon as it is stored in the cache pool LV.
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 4956a3f..444c7c0 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -4,14 +4,11 @@ lvmetad \- LVM metadata cache daemon
 .SH SYNOPSIS
 .B lvmetad
 .RB [ \-l
-.RI {all|wire|debug}
-.RB ]
+.RI { all | wire | debug }]
 .RB [ \-p
-.RI pidfile_path
-.RB ]
+.IR pidfile_path ]
 .RB [ \-s
-.RI socket_path
-.RB ]
+.IR socket_path ]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-V ]
@@ -34,7 +31,7 @@ Don't fork, but run in the foreground.
 .BR \-h ", " \-?
 Show help information.
 .TP
-.BR \-l " {" \fIall | \fIwire | \fIdebug }
+.IR \fB\-l " {" all | wire | debug }
 Select the type of log messages to generate.
 Messages are logged by syslog.  
 Additionally, when -f is given they are also sent to standard error.


