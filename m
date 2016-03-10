From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:11 +0000 (UTC)
Subject: master - man: updates
Message-ID: <20160310174011.53D1660804@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=386208e5933ea40792c402bce17f3ff106aa3353
Commit:        386208e5933ea40792c402bce17f3ff106aa3353
Parent:        86a23b2145e4abde3086a22ceb15438515b0053d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 3 20:27:09 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

man: updates

Continuing with lvconvert style updates.

Minimize usage of '\:' as zero-width break space, since html renderers
do not handle this groff sign well (some of them seems to even render
':' there).
But since we do not want see badly rendered man pages itself, prefer
the 'man visual' appearence over html page generation (man2html should
be actually fixed).

Start to use 'user input option' with Capitals more consistently.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   71 +++++++++++++++++++++++++--------------------------
 man/lvcreate.8.in  |   26 +++++++++---------
 man/lvmconfig.8.in |   25 +++++++++---------
 4 files changed, 61 insertions(+), 62 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d348cbc..685cdad 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.146 - 
 =================================
+  More man page cleanups in lvconvert.
   Fix makefile vpath in /udev when generating udev rules files.
   Another attempt to improve VG name parsing for lvconvert (2.02.144).
   Use new cache status info and skip flushing for failed cache.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index b889345..12aaea2 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -33,7 +33,7 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-version ]
 .IR LogicalVolume
-.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
 .sp
 .B lvconvert
 .BR \-\-merge
@@ -90,7 +90,7 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .IR MirrorLogicalVolume
 .RB [ \-\-commandprofile
 .IR ProfileName ]
-.RI [ SplittablePhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.RI \%[ SplittablePhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
 .sp
 .B lvconvert
 .BR \-\-splitsnapshot
@@ -156,7 +156,7 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .IR LogicalVolume
-.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]
 .sp
 .B lvconvert
 .BR \-\-type
@@ -179,7 +179,7 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-stripes
 .IR Stripes
 .RB [ \-I | \-\-stripesize
-.IR StripeSize ]]]
+.IR StripeSize ]]
 .RB [ \-\-poolmetadataspare
 .RB { y | n }]
 .RB [ \-Z | \-\-zero
@@ -189,8 +189,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [[ ExternalOrigin | ThinPool ] LogicalVolume ]
-.RI [ PhysicalVolume [ Path ]\:[ \fB: \fIPE \fR[ \fB\- PE ]]...]
+.RI [[ ExternalOrigin | ThinPool ] LogicalVolume
+.RI \%[ PhysicalVolume [ Path ][ \fB: \fIPE \fR[ \fB\- PE ]]...]]
 .ad b
 .sp
 .
@@ -257,14 +257,14 @@ version available in newer kernels.
 .
 .HP
 .BR \-\-cachepool
-.IR CachePoolLV
+.IR CachePoolLogicalVolume { Name | Path }
 .br
 This argument is necessary when converting a logical volume to a cache LV.
 For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .
 .HP
 .BR \-\-cachesettings
-.IR Key \fB= Value
+.IB Key = Value
 .br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache tunable settings. In most use-cases, default values should be adequate.
@@ -337,21 +337,6 @@ be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
 .
 .HP
-.BR \-m ,
-.BR \-\-mirrors
-.IR Mirrors
-.br
-Specifies the degree of the mirror you wish to create.
-For example, "\fB\-m 1\fP" would convert the original logical
-volume to a mirror volume with 2-sides; that is, a
-linear volume plus one copy.  There are two implementations of mirroring
-which correspond to the "\fIraid1\fP" and "\fImirror\fP" segment types.  The default
-mirroring segment type is "\fIraid1\fP".  If the legacy "\fImirror\fP" segment type
-is desired, the \fB\-\-type\fP argument must be used to explicitly
-select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
-options below are only relevant to the legacy "\fImirror\fP" segment type.
-.
-.HP
 .BR \-\-mirrorlog
 .RB { disk | core | mirrored }
 .br
@@ -365,6 +350,21 @@ time the device is activated - perhaps, for example, after every reboot.
 Using \fBmirrored\fP will create a persistent log that is itself mirrored.
 .
 .HP
+.BR \-m ,
+.BR \-\-mirrors
+.IR Mirrors
+.br
+Specifies the degree of the mirror you wish to create.
+For example, "\fB\-m 1\fP" would convert the original logical
+volume to a mirror volume with 2-sides; that is, a
+linear volume plus one copy.  There are two implementations of mirroring
+which correspond to the \fBraid1\fP and \fBmirror\fP segment types.  The default
+mirroring segment type is \fBraid1\fP.  If the legacy \fBmirror\fP" segment type
+is desired, the \fB\-\-type\fP argument must be used to explicitly
+select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
+options below are only relevant to the legacy \fBmirror\fP segment type.
+.
+.HP
 .BR \-n ,
 .BR \-\-name
 .IR Name
@@ -402,7 +402,7 @@ as it is being used as the external origin.
 .
 .HP
 .BR \-\-poolmetadata
-.IR PoolMetadataLogicalVolume
+.IR PoolMetadataLogicalVolume { Name | Path }
 .br
 Specifies cache or thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
@@ -500,15 +500,6 @@ This option is only available to RAID segment types
 etc).
 .
 .HP
-.BR \-\-splitmirrors
-.IR Images
-.br
-The number of redundant \fIImages\fP of a mirror to be split off and used
-to form a new logical volume.  A name must be supplied for the
-newly-split-off logical volume using the \fB\-\-name\fP argument, unless
-the \fB\-\-trackchanges\fP argument is given.
-.
-.HP
 .BR \-s ,
 .BR \-\-snapshot ,
 .BR \-\-type\ snapshot
@@ -536,6 +527,15 @@ See also the option \fB\-\-uncache\fP for uncaching and removing
 cache pool with one command.
 .
 .HP
+.BR \-\-splitmirrors
+.IR Images
+.br
+The number of redundant \fIImages\fP of a mirror to be split off and used
+to form a new logical volume.  A name must be supplied for the
+newly-split-off logical volume using the \fB\-\-name\fP argument, unless
+the \fB\-\-trackchanges\fP argument is given.
+.
+.HP
 .BR \-\-splitsnapshot
 .br
 Separates \fISnapshotLogicalVolume\fP from its origin.
@@ -567,8 +567,7 @@ power of 2 but must not exceed the physical extent size.
 .HP
 .BR \-T ,
 .BR \-\-thin ,
-.BR \-\-type
-.BR thin
+.BR \-\-type\ thin
 .br
 Converts the logical volume into a thin logical volume of the thin pool
 specified with \fB\-\-thinpool\fP. The original logical volume
@@ -580,7 +579,7 @@ external origin volume for unprovisioned areas of any thin logical volume.
 .
 .HP
 .BR \-\-thinpool
-.IR ThinPoolLogicalVolume
+.IR ThinPoolLogicalVolume { Name | Path }
 .br
 Specifies or converts logical volume into a thin pool's data volume.
 Content of converted volume is lost.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 2ce39dd..f6bb14f 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -31,11 +31,11 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-cachemode
 .RB { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
-.IR policy ]
+.IR Policy ]
 .RB \%[ \-\-cachepool
 .IR CachePoolLogicalVolume ]
 .RB [ \-\-cachesettings
-.IR key \fB= value ]
+.IR Key \fB= Value ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
 .RB [ \-\-commandprofile
@@ -60,9 +60,9 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-minor
-.IR minor
+.IR Minor
 .RB [ \-j | \-\-major
-.IR major ]]
+.IR Major ]]
 .RB [ \-\-metadataprofile
 .IR Profile\%Name ]
 .RB [ \-m | \-\-mirrors
@@ -109,10 +109,10 @@ lvcreate \- create a logical volume in an existing volume group
 .RB { y | n }]
 .RB [ \-Z | \-\-zero
 .RB { y | n }]
-.RI [ VolumeGroup \c
-.RB [ / \c
-.RI { ExternalOrigin | Origin | Pool } LogicalVolumeName
-.RI [ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]]
+.RI [ VolumeGroup
+.RI |
+.RI \%{ ExternalOrigin | Origin | Pool } LogicalVolume
+.RI \%[ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]]
 .LP
 .B lvcreate
 .RB [ \-l | \-\-extents
@@ -132,7 +132,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB \%[ \-\-monitor
 .RB { y | n }]
 .RB [ \-n | \-\-name
-.IR SnapshotLogicalVolume ]
+.IR SnapshotLogicalVolumeName ]
 .BR \-s | \-\-snapshot | \-H | \-\-cache
 .RI \%{[ VolumeGroup \fB/\fP] OriginalLogicalVolume
 .RB \%[ \-V | \-\-virtualsize
@@ -223,7 +223,7 @@ cache pool LV.
 .
 .HP
 .BR \-\-cachepolicy
-.IR policy
+.IR Policy
 .br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache policy. \fBmq\fP is the basic policy name. \fBsmq\fP is more advanced
@@ -238,7 +238,7 @@ is to append name to Volume group name argument.
 .
 .HP
 .BR \-\-cachesettings
-.IB key = value
+.IB Key = Value
 .br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache tunable settings. In most use-cases, default values should be adequate.
@@ -336,7 +336,7 @@ to be allocated (including extents used by any mirrors, for example).
 .
 .HP
 .BR \-j | \-\-major
-.IR major
+.IR Major
 .br
 Sets the major number.
 Major numbers are not supported with pool volumes.
@@ -356,7 +356,7 @@ See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
 .
 .HP
 .BR \-\-minor
-.IR minor
+.IR Minor
 .br
 Sets the minor number.
 Minor numbers are not supported with pool volumes.
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 9a3fcab..257029e 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -6,15 +6,14 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .ad l
 .B lvmconfig
 .RB [ \-f | \-\-file
-.IR filename ]
+.IR Filename ]
 .RB [ \-\-type
-.RB { current |\: default |\: diff |\: full | list |\: missing \c
-.RB |\: new |\: profilable |\: profilable-command \c
-.RB |\: profilable-metadata }]
+.RB { current | default | diff | full |\: list | missing | new \c
+.RB | profilable | profilable-command | profilable-metadata }]
 .RB [ \-\-atversion
-.IR version ]
+.IR Version ]
 .RB [ \-\-sinceversion
-.IR version ]
+.IR Version ]
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
 .RB [ \-\-ignorelocal ]
@@ -45,7 +44,7 @@ The command was added in release 2.02.119 and has an identical longer form
 
 .SH OPTIONS
 .TP
-.BR \-f ", " \-\-file " \fIfilename"
+.BR \-f ", " \-\-file " \fIFilename"
 Send output to a file named 'filename'.
 
 .TP
@@ -54,7 +53,7 @@ List configuration settings with summarizing comment. This is the same as using
 \fBlvmconfig --type list --withsummary\fP.
 
 .TP
-.BR \-\-type " {" current | default | diff | full | missing | new | profilable | profilable-command | profilable-metadata }
+.BR \-\-type " {" current | default | diff | full | missing | new | profilable |\: profilable-command | profilable-metadata }
 Select the type of configuration to display. The configuration settings
 displayed have either default values or currently-used values assigned based on
 the type selected. If no type is selected, \fB\-\-type current\fP is used
@@ -106,7 +105,7 @@ by \fB\-\-type profilable\fP.
 .RE
 
 .TP
-.BI \-\-atversion " version"
+.BI \-\-atversion " Version"
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 When configuration is displayed, the configuration settings recognized
@@ -116,7 +115,7 @@ which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 
 .TP
-.BI \-\-sinceversion " version"
+.BI \-\-sinceversion " Version"
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with \fB\-\-type new\fP
@@ -140,13 +139,13 @@ Ignore local section.
 
 .TP
 .BI \-\-config " ConfigurationString"
-Use \fBConfigurationString\fP to override existing configuration.
+Use \fIConfigurationString\fP to override existing configuration.
 This configuration is then applied for the lvmconfig command itself.
 See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
 
 .TP
 .BI \-\-commandprofile " ProfileName"
-Use \fBProfileName\fP to override existing configuration.
+Use \fIProfileName\fP to override existing configuration.
 This configuration is then applied for the lvmconfig command itself.
 See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for
 more info about \fBconfig cascade\fP.
@@ -158,7 +157,7 @@ applied for the lvmconfig command itself.
 
 .TP
 .BI \-\-metadataprofile " ProfileName"
-Use \fBProfileName\fP to override existing configuration.
+Use \fIProfileName\fP to override existing configuration.
 The configuration defined in metadata profile has no effect for
 the lvmconfig command itself. lvmconfig displays the configuration only.
 See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for more


