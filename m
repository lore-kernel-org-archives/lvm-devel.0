From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 14:21:12 -0400
Subject: master - man lvmraid: use same style as generated pages
Message-ID: <201704111821.v3BILCE4020719@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c448dcb3491cbb54e9382b2b40a719ad87974079
Commit:        c448dcb3491cbb54e9382b2b40a719ad87974079
Parent:        04d7444afa88f1f4e56065888124fff775a5638f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 13:13:49 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 13:20:54 2017 -0500

man lvmraid: use same style as generated pages

---
 man/lvmraid.7_main |   51 ++++++++++++++++++++++++++-------------------------
 1 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 99218a5..4d117c4 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -45,7 +45,7 @@ The basic RAID levels that can be used are:
 To display the LV type of an existing LV, run:
 
 .B lvs -o name,segtype
-\fIVG\fP/\fILV\fP
+\fILV\fP
 
 (The LV type is also referred to as "segment type" or "segtype".)
 
@@ -306,7 +306,7 @@ The command to scrub a RAID LV can operate in two different modes:
 
 .B lvchange --syncaction
 .BR check | repair
-.IR VG / LV
+.I LV
 
 .HP
 .B check
@@ -325,20 +325,20 @@ the RAID LV.  To control the I/O rate used for scrubbing, use:
 
 .HP
 .B --maxrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+\fISize\fP[k|UNIT]
 .br
-Sets the maximum recovery rate for a RAID LV.  \fIRate\fP is specified as
+Sets the maximum recovery rate for a RAID LV.  \fISize\fP is specified as
 an amount per second for each device in the array.  If no suffix is given,
-then KiB/sec/device is assumed.  Setting the recovery rate to \fB0\fP
+then KiB/sec/device is used.  Setting the recovery rate to \fB0\fP
 means it will be unbounded.
 
 .HP
 .BR --minrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
+\fISize\fP[k|UNIT]
 .br
-Sets the minimum recovery rate for a RAID LV.  \fIRate\fP is specified as
+Sets the minimum recovery rate for a RAID LV.  \fISize\fP is specified as
 an amount per second for each device in the array.  If no suffix is given,
-then KiB/sec/device is assumed.  Setting the recovery rate to \fB0\fP
+then KiB/sec/device is used.  Setting the recovery rate to \fB0\fP
 means it will be unbounded.
 
 .P
@@ -616,8 +616,8 @@ A RAID LV that is missing devices may be activated or not, depending on
 the "activation mode" used in lvchange:
 
 .B lvchange -ay --activationmode
-.RB { complete | degraded | partial }
-.IR VG / LV
+.BR complete | degraded | partial
+.I LV
 
 .B complete
 .br
@@ -655,12 +655,12 @@ repeated to replace multiple PVs.  Replacement devices can be optionally
 listed with either option.
 
 .B lvconvert --repair
-.IR VG / LV
+.I LV
 [\fINewPVs\fP]
 
 .B lvconvert --replace
 \fIOldPV\fP
-.IR VG / LV
+.I LV
 [\fINewPV\fP]
 
 .B lvconvert
@@ -669,7 +669,7 @@ listed with either option.
 .B --replace
 \fIOldPV2\fP
 ...
-.IR VG / LV
+.I LV
 [\fINewPVs\fP]
 
 New devices require synchronization with existing devices, see
@@ -685,7 +685,7 @@ in the RAID LV operating in degraded mode until it is reactivated.  Use
 the lvchange command to refresh an LV:
 
 .B lvchange --refresh
-.IR VG / LV
+.I LV
 
 .nf
 # lvs -o name,vgname,segtype,attr,size vg
@@ -727,7 +727,7 @@ synchronization is started.
 The specific command run by dmeventd to warn or repair is:
 .br
 .B lvconvert --repair --use-policies
-.IR VG / LV
+.I LV
 
 
 .SS Corrupted Data
@@ -742,8 +742,9 @@ This should be rare, and can be detected (see \fBScrubbing\fP).
 If specific PVs in a RAID LV are known to have corrupt data, the data on
 those PVs can be reconstructed with:
 
-.B lvchange --rebuild PV
-.IR VG / LV
+.B lvchange --rebuild
+.I PV
+.I LV
 
 The rebuild option can be repeated with different PVs to replace the data
 on multiple PVs.
@@ -789,8 +790,8 @@ while all devices are still written to.
 
 .B lvchange
 .BR -- [ raid ] writemostly
-.BR \fIPhysicalVolume [ : { y | n | t }]
-.IR VG / LV
+\fIPV\fP[\fB:y\fP|\fBn\fP|\fBt\fP]
+.I LV
 
 The specified device will be marked as "write mostly", which means that
 reading from this device will be avoided, and other devices will be
@@ -816,8 +817,8 @@ will not complete until writes to all the mirror images are complete.
 
 .B lvchange
 .BR -- [ raid ] writebehind
-.IR IOCount
-.IR VG / LV
+.I Number
+.I LV
 
 To report the current write behind setting, run:
 
@@ -836,7 +837,7 @@ using lvconvert and specifying the new RAID level as the LV type:
 
 .B lvconvert --type
 .I RaidLevel
-\fIVG\fP/\fILV\fP
+.I LV
 [\fIPVs\fP]
 
 The most common and recommended RAID takeover conversions are:
@@ -1657,7 +1658,7 @@ The command to start duplication is:
 [\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 .RS
 .B --duplicate
-.IR VG / LV
+.I LV
 [\fIPVs\fP]
 .RE
 
@@ -1707,7 +1708,7 @@ the new devices, specify the name of SubLV 0 (suffix _dup_0):
 .B lvconvert --unduplicate
 .BI --name
 .IB LV _dup_0
-.IR VG / LV
+.I LV
 
 To make the RAID LV use the data copy on the new devices, and drop the old
 devices, specify the name of SubLV 1 (suffix _dup_1):
@@ -1715,7 +1716,7 @@ devices, specify the name of SubLV 1 (suffix _dup_1):
 .B lvconvert --unduplicate
 .BI --name
 .IB LV _dup_1
-.IR VG / LV
+.I LV
 
 FIXME: To make the LV use the data on the original devices, but keep the
 data copy as a new LV, ...


