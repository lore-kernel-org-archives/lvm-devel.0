From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 13:50:09 +0000 (UTC)
Subject: master - man: update
Message-ID: <20141124135009.CF28A613B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d184e8d0bac11f64ec7a5e8dc2a0fcd5b2714890
Commit:        d184e8d0bac11f64ec7a5e8dc2a0fcd5b2714890
Parent:        74e6135c4f06f922672a057e7c47f513e84d035d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 14:48:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 14:48:13 2014 +0100

man: update

Improve lvconvert.
Put ENV section downward in lvm.8.
---
 man/lvconvert.8.in |   26 +++++++++++++-------------
 man/lvm.8.in       |   50 +++++++++++++++++++++++++-------------------------
 2 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 5c9c083..10bc478 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -119,21 +119,21 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RI [ PhysicalVolume [ Path ]...]
 .sp
 .B lvconvert
-.RB [{ \-\-type
-.BR \fIthin [ \fI\-pool ]| \-T | \-\-thin }
+.B \-\-type
+.BR \fIthin [ \fI\-pool ]| \-T | \-\-thin
 .RB [ \-\-originname
-.IR NewExternalOriginVolumeName ]]
+.IR NewExternalOriginVolumeName ]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
-.RB [{ \-\-poolmetadata
+.RB [ \-\-poolmetadata
 .IR ThinPoolMetadataLogicalVolume { Name | Path }
 |
 .B \-\-poolmetadatasize
-.IR ThinPoolMetadataSize [ bBsSkKmMgG ]}]
+.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-stripes \ \fIStripes
@@ -148,25 +148,25 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-version ]
 .RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
 .RI [ PhysicalVolume [ Path ][ :PE
-.RI [ \-PE ]]...]
+.RI [ \-PE ]]\ \.\|\.\|\.
 .sp
 .B lvconvert
-.RB [ \-\-type
-.BR \fIcache [ \fI\-pool ]| \-H | \-\-cache ]
-.RB [{ \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }]
+.B \-\-type
+.BR \fIcache [ \fI\-pool ]| \-H | \-\-cache
+.RB [ \-\-cachepool
+.IR CachePoolLogicalVolume { Name | Path }
 |
 .B \-\-pooldatasize
-.IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]}]
+.IR CachePoolMetadataSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
 .RI { writeback | writethrough }]
-.RB [{ \-\-poolmetadata
+.RB [ \-\-poolmetadata
 .IR CachePoolMetadataLogicalVolume { Name | Path }
 |
 .B \-\-poolmetadatasize
-.IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
+.IR CachePoolMetadataSize [ bBsSkKmMgG ]]
 .RB [ \-\-poolmetadataspare
 .RI { y | n }]
 .RB [ \-\-commandprofile
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 7b95e2b..5347e94 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -308,36 +308,12 @@ A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
 for any other command (with the exception of \fBdumpconfig\fP command where the
 \-\-profile has special meaning, see \fBlvm dumpconfig\fP(8) for more information).
 .TP
-.IR \fB\-\-config \ ConfigurationString
+.IR \fB\-\-config " " \fIConfigurationString
 Uses the ConfigurationString as direct string representation of the configuration
 to override the existing configuration. The ConfigurationString is of exactly
 the same format as used in any LVM configuration file. See \fBlvm.conf\fP(5)
 for more information about \fBdirect config override on command line\fP and the
 way it fits with other LVM configuration methods.
-.SH ENVIRONMENT VARIABLES
-.TP
-.B HOME
-Directory containing \fI.lvm_history\fP if the internal readline
-shell is invoked.
-.TP
-.B LVM_SYSTEM_DIR
-Directory containing \fBlvm.conf\fP(5) and other LVM system files.
-Defaults to "#DEFAULT_SYS_DIR#".
-.TP
-.B LVM_SUPPRESS_FD_WARNINGS
-Suppress warnings about openned file descriptors, when lvm command
-is executed.
-.TP
-.B LVM_VG_NAME
-The Volume Group name that is assumed for
-any reference to a Logical Volume that doesn't specify a path.
-Not set by default.
-.TP
-.B LVM_LVMETAD_PIDFILE
-Path for the lvmetad pid file.
-.TP
-.B LVM_LVMETAD_SOCKET
-Path for the lvmetad socket file.
 .SH VALID NAMES
 The valid characters for VG and LV names are:
 .B a-z A-Z 0-9 + _ . -
@@ -498,6 +474,30 @@ For scalar types: number (integer), size (floating point number with size unit s
 
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
+.SH ENVIRONMENT VARIABLES
+.TP
+.B HOME
+Directory containing \fI.lvm_history\fP if the internal readline
+shell is invoked.
+.TP
+.B LVM_SYSTEM_DIR
+Directory containing \fBlvm.conf\fP(5) and other LVM system files.
+Defaults to "#DEFAULT_SYS_DIR#".
+.TP
+.B LVM_SUPPRESS_FD_WARNINGS
+Suppress warnings about openned file descriptors, when lvm command
+is executed.
+.TP
+.B LVM_VG_NAME
+The Volume Group name that is assumed for
+any reference to a Logical Volume that doesn't specify a path.
+Not set by default.
+.TP
+.B LVM_LVMETAD_PIDFILE
+Path for the lvmetad pid file.
+.TP
+.B LVM_LVMETAD_SOCKET
+Path for the lvmetad socket file.
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br


