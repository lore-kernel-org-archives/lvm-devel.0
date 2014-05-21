From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 12:54:15 +0000 (UTC)
Subject: master - man: more man page updates for --commandprofile and --metadataprofile split
Message-ID: <20140521125415.08336602C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e78092fa3a4cba95ccc8820fb2b2c617e2b0f618
Commit:        e78092fa3a4cba95ccc8820fb2b2c617e2b0f618
Parent:        b7431f69ed0e8b3b153b5c5dc1e3fbf990d059b0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 14:53:56 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 14:53:56 2014 +0200

man: more man page updates for --commandprofile and --metadataprofile split

---
 man/lvchange.8.in     |   19 ++++++++++++++-----
 man/lvconvert.8.in    |   20 ++++++++++++++++++++
 man/lvcreate.8.in     |   15 +++++++++++++++
 man/lvdisplay.8.in    |    4 ++++
 man/lvextend.8.in     |    2 ++
 man/lvm.8.in          |   26 ++++++++++++++++++--------
 man/lvm.conf.5.in     |    4 ++--
 man/lvmdiskscan.8.in  |    2 ++
 man/lvreduce.8.in     |    2 ++
 man/lvremove.8.in     |    2 ++
 man/lvrename.8.in     |    2 ++
 man/lvresize.8.in     |    2 ++
 man/lvs.8.in          |    2 ++
 man/lvscan.8.in       |    2 ++
 man/pvchange.8.in     |    2 ++
 man/pvck.8.in         |    2 ++
 man/pvcreate.8.in     |    2 ++
 man/pvdisplay.8.in    |    4 ++++
 man/pvmove.8.in       |    2 ++
 man/pvremove.8.in     |    2 ++
 man/pvresize.8.in     |    2 ++
 man/pvs.8.in          |    2 ++
 man/pvscan.8.in       |    2 ++
 man/vgcfgbackup.8.in  |    2 ++
 man/vgcfgrestore.8.in |    2 ++
 man/vgchange.8.in     |   19 ++++++++++++++-----
 man/vgck.8.in         |    2 ++
 man/vgconvert.8.in    |    2 ++
 man/vgcreate.8.in     |   11 +++++++++++
 man/vgdisplay.8.in    |    4 ++++
 man/vgexport.8.in     |    2 ++
 man/vgextend.8.in     |    2 ++
 man/vgmerge.8.in      |    2 ++
 man/vgmknodes.8.in    |    2 ++
 man/vgreduce.8.in     |    2 ++
 man/vgremove.8.in     |    2 ++
 man/vgrename.8.in     |    2 ++
 man/vgs.8.in          |    2 ++
 man/vgscan.8.in       |    2 ++
 man/vgsplit.8.in      |    2 ++
 40 files changed, 166 insertions(+), 20 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index b138c3d..56a35af 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -13,13 +13,13 @@ lvchange \- change attributes of a logical volume
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-C | \-\-contiguous
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
-.RB [ \-\-profile
-.IR ProfileName ]
 .RB [ \-\-detachprofile ]
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
@@ -44,6 +44,8 @@ lvchange \- change attributes of a logical volume
 .IR PhysicalVolume [ : { t | n | y }]]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-M | \-\-persistent
 .RI { y | n }]
 .RB [ \-\-minor
@@ -103,9 +105,9 @@ logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
 .BR \-\-detachprofile
-Detach any configuration profiles attached to given Logical Volumes.
-See also \fBlvm\fP(8) and \fBlvm.conf\fP(5) for more
-information about configuration profiles.
+Detach any metadata configuration profiles attached to given
+Logical Volumes. See \fBlvm.conf\fP(5) for more information
+about \fBmetadata profiles\fP.
 .TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Set this to \fIignore\fP to ignore any discards received by a
@@ -123,6 +125,13 @@ and copied to the others, so this can take a considerable amount of
 time - and during this time you are without a complete redundant copy
 of your data.
 .TP
+.B \-\-metadataprofile \fIProfileName
+Uses and attaches ProfileName configuration profile to the logical
+volume metadata. Whenever the logical volume is processed next time,
+the profile is automatically applied. If the volume group has another
+profile attached, the logical volume profile is preferred.
+See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+.TP
 .B \-\-minor \fIminor
 Set the minor number.
 .TP
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 91c5bee..2833f20 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -15,6 +15,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-A | \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-b | \-\-background ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-f | \-\-force ]
 .RB [ \-i | \-\-interval
 .IR Seconds ]
@@ -31,6 +33,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
 .sp
 .B lvconvert \-\-splitmirrors \fIImages
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-\-name
 .IR SplitLogicalVolumeName ]
 .RB [ \-\-trackchanges ]
@@ -39,6 +43,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert
 .BR \-\-splitsnapshot
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-v | \-\-verbose ]
@@ -47,6 +53,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert
 .BR \-s | \-\-snapshot
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkK ]]
 .RB [ \-h | \-? | \-\-help ]
@@ -59,6 +67,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR SnapshotLogicalVolume [ Path ]
 .sp
 .B lvconvert \-\-merge
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-b | \-\-background ]
 .RB [ \-i | \-\-interval
 .IR Seconds ]
@@ -68,6 +78,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR LogicalVolume [ Path ]...
 .sp
 .B lvconvert \-\-repair
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-stripes
 .I Stripes
@@ -79,6 +91,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RI [ PhysicalVolume [ Path ]...]
 .sp
 .B lvconvert \-\-replace \fIPhysicalVolume
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -87,6 +101,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .sp
 .B lvconvert \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-discards
@@ -114,6 +130,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-\-version ]
 .sp
 .B lvconvert \-\-type \fIcache-pool
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -133,6 +151,8 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .B \-\-cachepool
 .IR CachePoolLV { Name | Path }
 .IR LogicalVolume [ Path ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4e7612a..78cef80 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -14,12 +14,16 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-C | \-\-contiguous
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-ignoremonitoring ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-\-monitor
 .RI { y | n }]
 .RB [ \-\-[raid]maxrecoveryrate
@@ -92,8 +96,12 @@ lvcreate \- create a logical volume in an existing volume group
 .IR LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkK ]]
+.RB [ \-\-commandprofile
+.IR Profilename ]
 .RB [ \-\-noudevsync ]
 .RB [ \-\-ignoremonitoring ]
+.RB [ \-\-metadataProfile
+.IR ProfileName ]
 .RB [ \-\-monitor
 .RI { y | n }]
 .RB [ \-n | \-\-name
@@ -276,6 +284,13 @@ will create a persistent log that is itself mirrored.
 When the legacy "mirror" segment type is used, the optional argument
 \fB\-\-corelog\fP is equivalent to \fB\-\-mirrorlog\fP \fIcore\fP.
 .TP
+.BR \-\-metadataprofile \fIProfileName
+Uses and attaches the ProfileName configuration profile to the logical
+volume metadata. Whenever the logical volume is processed next time,
+the profile is automatically applied. If the volume group has another
+profile attached, the logical volume profile is preferred.
+See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+.TP
 .IR \fB\-M ", " \fB\-\-persistent " {" y | n }
 Set to \fIy\fP to make the minor number specified persistent.
 .TP
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 8348879..a9f3d49 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -5,6 +5,8 @@ lvdisplay \- display attributes of a logical volume
 .B lvdisplay
 .RB [ \-a | \-\-all ]
 .RB [ \-c | \-\-colon ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -24,6 +26,8 @@ lvdisplay \- display attributes of a logical volume
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
 .RB [ \-a | \-\-all ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index d9bc0c8..845a3ea 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -7,6 +7,8 @@ lvextend \- extend the size of a logical volume
 .IR AllocationPolicy ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-f | \-\-force ]
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 41223b0..c753561 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -281,16 +281,26 @@ an allocation request but \fInormal\fP doesn't use them,
 \fIanywhere\fP will - even if that reduces performance by
 placing two stripes on the same Physical Volume.
 .TP
-.IR \fB\-\-profile \ ProfileName
-Selects the configuration profile to use when processing an LVM command.
-In addition to that, when creating a Volume Group or a Logical Volume,
-it causes the ProfileName to be stored in metadata for each Volume Group
-or Logical Volume. If the profile is stored in metadata, it is automatically
-applied next time the Volume Group or the Logical Volume is processed and the
-use of --profile is not necessary when running LVM commands further. See also
-\fBlvm.conf\fP(5) for more information about \fBprofile config\fP and the
+.IR \fB\-\-commandprofile \fIProfileName
+Selects the command configuration profile to use when processing an LVM command.
+See also \fBlvm.conf\fP(5) for more information about \fBcommand profile config\fP and
+the way it fits with other LVM configuration methods.
+.TP
+.IR \fB\-\-metadataprofile \fIProfileName
+Selects the metadata configuration profile to use when processing an LVM command.
+When using metadata profile during Volume Group or Logical Volume creation,
+the metadata profile name is saved in metadata. When such Volume Group or Logical
+Volume is processed next time, the metadata profile is automatically applied
+and the use of \-\-metadataprofile option is not necessary. See also
+\fBlvm.conf\fP(5) for more information about \fBmetadata profile config\fP and the
 way it fits with other LVM configuration methods.
 .TP
+.IR \fB\-\-profile \fIProfileName
+A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
+\fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
+for any other command (with the exception of \fBdumpconfig\fP command where the
+\-\-profile has special meaning, see \fBlvm dumpconfig\fP(8) for more information).
+.TP
 .IR \fB\-\-config \ ConfigurationString
 Uses the ConfigurationString as direct string representation of the configuration
 to override the existing configuration. The ConfigurationString is of exactly
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index e64e2a3..bf73a29 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -47,7 +47,7 @@ any of its Logical Volumes have different profiles defined, the profile
 defined for the Logical Volume is preferred. The metadata profile can be
 attached/detached by using the \fBlvchange\fP and \fBvgchange\fP commands
 and their \fB\-\-metadataprofile ProfileName\fP and
-\fB\-\-detachprofile ProfileName\fP options or the \fB\-\-metadataprofile\fP
+\fB\-\-detachprofile\fP options or the \fB\-\-metadataprofile\fP
 option during creation when using \fBvgcreate\fP or \fBlvcreate\fP command.
 The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP
 and \fB-o lv_profile\fP output options to show the metadata profile
@@ -64,7 +64,7 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for command profiles) and \fBmetadata_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
-profiles and edit it as needed. Alternatively, the
+profiles and edit them as needed. Alternatively, the
 \fBlvm dumpconfig --file <ProfileName.profile> --type profilable-command <section>\fP
 or \fBlvm dumpconfig --file <ProfileName.profile> --type profilable-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
diff --git a/man/lvmdiskscan.8.in b/man/lvmdiskscan.8.in
index 7b3e08b..c35d071 100644
--- a/man/lvmdiskscan.8.in
+++ b/man/lvmdiskscan.8.in
@@ -3,6 +3,8 @@
 lvmdiskscan \- scan for all devices visible to LVM2
 .SH SYNOPSIS
 .B lvmdiskscan
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-l | \-\-lvmpartition ]
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 2b0f3f8..852ef0b 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -5,6 +5,8 @@ lvreduce \- reduce the size of a logical volume
 .B lvreduce
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
index 1d48a11..245b6e6 100644
--- a/man/lvremove.8.in
+++ b/man/lvremove.8.in
@@ -5,6 +5,8 @@ lvremove \- remove a logical volume
 .B lvremove
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/lvrename.8.in b/man/lvrename.8.in
index ea640ae..b299fa2 100644
--- a/man/lvrename.8.in
+++ b/man/lvrename.8.in
@@ -5,6 +5,8 @@ lvrename \- rename a logical volume
 .B lvrename
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index 75d20a0..52f9e38 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -5,6 +5,8 @@ lvresize \- resize a logical volume
 .B lvresize
 .RB [ \-\-alloc " " \fIAllocationPolicy ]
 .RB [ \-\-noudevsync ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-i | \-\-stripes " " \fIStripes
 .RB [ \-I | \-\-stripesize " " \fIStripeSize ]]
 .RB {[ \-l | \-\-extents
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 7297ee9..43d79d8 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -5,6 +5,8 @@ lvs \- report information about logical volumes
 .B lvs
 .RB [ \-\-aligned ]
 .RB [ \-a | \-\-all ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index 5102691..001f544 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -5,6 +5,8 @@ lvscan \- scan (all disks) for Logical Volumes
 .B lvscan
 .RB [ \-a | \-\-all]
 .RB [ \-b | \-\-blockdevice ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 5e6c15e..6fe3e3d 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -7,6 +7,8 @@ pvchange \- change attributes of a physical volume
 .IR Tag ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-force ]
 .RB [ \-\-deltag
diff --git a/man/pvck.8.in b/man/pvck.8.in
index e6019af..4308196 100644
--- a/man/pvck.8.in
+++ b/man/pvck.8.in
@@ -3,6 +3,8 @@
 pvck \- check physical volume metadata
 .SH SYNOPSIS
 .B pvck
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 9353c6c..76a0abb 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -3,6 +3,8 @@
 pvcreate \- initialize a disk or partition for use by LVM
 .SH SYNOPSIS
 .B pvcreate
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index b2a2577..f317bcc 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -4,6 +4,8 @@ pvdisplay \- display attributes of a physical volume
 .SH SYNOPSIS
 .B pvdisplay
 .RB [ \-c | \-\-colon ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -25,6 +27,8 @@ pvdisplay \- display attributes of a physical volume
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
 .RB [ \-a | \-\-all ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index bb69547..39e6cbf 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -7,6 +7,8 @@ pvmove \- move physical extents
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-b | \-\-background ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-i | \-\-interval
diff --git a/man/pvremove.8.in b/man/pvremove.8.in
index 5029228..abf1ca9 100644
--- a/man/pvremove.8.in
+++ b/man/pvremove.8.in
@@ -3,6 +3,8 @@
 pvremove \- remove a physical volume
 .SH SYNOPSIS
 .B pvremove
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/pvresize.8.in b/man/pvresize.8.in
index 59539b8..14e459c 100644
--- a/man/pvresize.8.in
+++ b/man/pvresize.8.in
@@ -3,6 +3,8 @@
 pvresize \- resize a disk or partition in use by LVM2
 .SH SYNOPSIS
 .B pvresize
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 67e395b..9f9cde8 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -5,6 +5,8 @@ pvs \- report information about physical volumes
 .B pvs
 .RB [ \-a | \-\-all ]
 .RB [ \-\-aligned ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 61b15d0..19ca3fc 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -3,6 +3,8 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgcfgbackup.8.in b/man/vgcfgbackup.8.in
index ce8db8b..2bfebc6 100644
--- a/man/vgcfgbackup.8.in
+++ b/man/vgcfgbackup.8.in
@@ -3,6 +3,8 @@
 vgcfgbackup \- backup volume group descriptor area
 .SH SYNOPSIS
 .B vgcfgbackup
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file
 .RI < filename >]
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
index ac84300..752fc56 100644
--- a/man/vgcfgrestore.8.in
+++ b/man/vgcfgrestore.8.in
@@ -3,6 +3,8 @@
 vgcfgrestore \- restore volume group descriptor area
 .SH SYNOPSIS
 .B vgcfgrestore
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file
 .RI < filename >]
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 16adf4df..d756811 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -20,11 +20,11 @@ vgchange \- change attributes of a volume group
 .RB [ \-c | \-\-clustered
 .RI { y | n }]
 .RB [ \-u | \-\-uuid ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
-.RB [ \-\-profile
-.IR ProfileName ]
 .RB [ \-\-detachprofile ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -36,6 +36,8 @@ vgchange \- change attributes of a volume group
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ \-\- [ vg ] metadatacopies ]
 .IR NumberOfCopies | unmanaged | all ]
 .RB [ \-P | \-\-partial ]
@@ -99,9 +101,9 @@ particular time, you may still be able to use Volume Groups that
 are not marked as clustered.
 .TP
 .BR \-\-detachprofile
-Detach any configuration profiles attached to given Volume Groups.
-See also \fBlvm\fP(8) and \fBlvm.conf\fP(5) for more
-information about configuration profiles.
+Detach any metadata configuration profiles attached to given
+Volume Groups. See \fBlvm.conf\fP(5) for more information
+about \fBmetadata profiles\fP.
 .TP
 .BR \-u ", " \-\-uuid
 Generate new random UUID for specified Volume Groups.
@@ -169,6 +171,13 @@ a volume group with metadata in lvm2 format, for tool performance reasons,
 you should consider some use of \fB--pvmetadatacopies 0\fP as described in
 \fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
 .TP
+.BR \-\-metadataprofile " " \fIProfileName
+Uses and attaches ProfileName configuration profile to the volume group
+metadata. Whenever the volume group is processed next time, the profile
+is automatically applied. The profile is inherited by all logical volumes
+in the volume group unless the logical volume itself has its own profile
+attached. See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+.TP
 .BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
diff --git a/man/vgck.8.in b/man/vgck.8.in
index cc6cd57..56cbdb0 100644
--- a/man/vgck.8.in
+++ b/man/vgck.8.in
@@ -3,6 +3,8 @@
 vgck \- check volume group metadata
 .SH SYNOPSIS
 .B vgck
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
index 1e182b6..c77d529 100644
--- a/man/vgconvert.8.in
+++ b/man/vgconvert.8.in
@@ -3,6 +3,8 @@
 vgconvert \- convert volume group metadata format
 .SH SYNOPSIS
 .B vgconvert
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index e62df9e..a2340d3 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -11,12 +11,16 @@ vgcreate \- create a volume group
 .RI { y | n }]
 .RB [ \-c | \-\-clustered
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
 .RB [ -M | \-\-metadatatype
 .IR type ]
+.RB [ \-\-metadataprofile
+.IR ProfileName ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-\- [ vg ] metadatacopies
@@ -91,6 +95,13 @@ large numbers of physical volumes with metadata as it may be used to
 minimize metadata read and write overhead.
 The default value is \fIunmanaged\fP.
 .TP
+.BR \-\-metadataprofile " " \fIProfileName
+Uses and attaches the ProfileName configuration profile to the volume group
+metadata. Whenever the volume group is processed next time, the profile is
+automatically applied. The profile is inherited by all logical volumes in
+the volume group unless the logical volume itself has its own profile attached.
+See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
+.TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIbBsSkKmMgGtTpPeE ]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 7f50f83..bb2ead7 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -5,6 +5,8 @@ vgdisplay \- display attributes of volume groups
 .B vgdisplay
 .RB [ \-A | \-\-activevolumegroups ]
 .RB [ \-c | \-\-colon ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-s | \-\-short ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-d | \-\-debug ]
@@ -24,6 +26,8 @@ vgdisplay \- display attributes of volume groups
 .B vgdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/vgexport.8.in b/man/vgexport.8.in
index 7509170..2b31618 100644
--- a/man/vgexport.8.in
+++ b/man/vgexport.8.in
@@ -4,6 +4,8 @@ vgexport \- make volume groups unknown to the system
 .SH SYNOPSIS
 .B vgexport
 .RB [ \-a | \-\-all ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index ebb642f..ae7291c 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -5,6 +5,8 @@ vgextend \- add physical volumes to a volume group
 .B vgextend
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-restoremissing ]
diff --git a/man/vgmerge.8.in b/man/vgmerge.8.in
index 70db295..f67cffb 100644
--- a/man/vgmerge.8.in
+++ b/man/vgmerge.8.in
@@ -5,6 +5,8 @@ vgmerge \- merge two volume groups
 .B vgmerge
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-l | \-\-list ]
diff --git a/man/vgmknodes.8.in b/man/vgmknodes.8.in
index a0d9583..54fd3ec 100644
--- a/man/vgmknodes.8.in
+++ b/man/vgmknodes.8.in
@@ -3,6 +3,8 @@
 vgmknodes \- recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-refresh ]
diff --git a/man/vgreduce.8.in b/man/vgreduce.8.in
index 734f01e..141533e 100644
--- a/man/vgreduce.8.in
+++ b/man/vgreduce.8.in
@@ -6,6 +6,8 @@ vgreduce \- reduce a volume group
 .RB [ \-a | \-\-all ]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-removemissing ]
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
index c205e8a..d17db10 100644
--- a/man/vgremove.8.in
+++ b/man/vgremove.8.in
@@ -3,6 +3,8 @@
 vgremove \- remove a volume group
 .SH SYNOPSIS
 .B vgremove
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-force ]
 .RB [ \-h | \-? | \-\-help ]
diff --git a/man/vgrename.8.in b/man/vgrename.8.in
index 379f697..6951fb0 100644
--- a/man/vgrename.8.in
+++ b/man/vgrename.8.in
@@ -5,6 +5,8 @@ vgrename \- rename a volume group
 .B vgrename
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-t | \-\-test ]
diff --git a/man/vgs.8.in b/man/vgs.8.in
index eae60fa..c32195b 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -5,6 +5,8 @@ vgs \- report information about volume groups
 .B vgs
 .RB [ \-a | \-\-all ]
 .RB [ \-\-aligned ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/vgscan.8.in b/man/vgscan.8.in
index 1cdc8e1..c11b1ea 100644
--- a/man/vgscan.8.in
+++ b/man/vgscan.8.in
@@ -3,6 +3,8 @@
 vgscan \- scan all disks for volume groups and rebuild caches
 .SH SYNOPSIS
 .B vgscan
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
diff --git a/man/vgsplit.8.in b/man/vgsplit.8.in
index bdcfe3b..546d02f 100644
--- a/man/vgsplit.8.in
+++ b/man/vgsplit.8.in
@@ -9,6 +9,8 @@ vgsplit \- split a volume group into two
 .RI { y | n }]
 .RB [ \-c | \-\-clustered
 .RI { y | n }]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes


