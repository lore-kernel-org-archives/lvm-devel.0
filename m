From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Mar 2017 14:37:52 -0400
Subject: master - commands: fix lvcreate mirrors/stripes options
Message-ID: <201703131837.v2DIbqDH032487@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49cd54fc3a4cfbe785ba387a3c748362f74ea52f
Commit:        49cd54fc3a4cfbe785ba387a3c748362f74ea52f
Parent:        46b735c937ce68e72d08997635321bf30240325d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 10 15:57:26 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 13 13:37:07 2017 -0500

commands: fix lvcreate mirrors/stripes options

Systematically outline every combination of:
--type striped, --type mirror, --type raid, --mirrors, --stripes
and make sure each is assigned to one specific cmd def.

This revealed that a new command def is needed for
lvcreate that uses both --mirrors and --stripes
but no --type option.

The use of LVCREATE_RAID shortcut for an option set
resulted in mirrors/stripes being included in optional
opts set when they were already in the required list.
---
 tools/command-lines.in |   55 ++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index e4e956c..2fec553 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -706,9 +706,6 @@ OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksi
 
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
-OO_LVCREATE_RAID: --mirrors PNumber, --stripes Number, --stripesize SizeKB,
---regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB
-
 ---
 
 lvcreate --type error --size SizeMB VG
@@ -744,6 +741,33 @@ DESC: Create a linear LV.
 
 ---
 
+# all lvcreate combinations of:
+# a) --type striped
+# b) --type mirror
+# c) --type raid<N>
+# d) --stripes
+# e) --mirrors
+#
+# R1.  a:     striped with default stripes
+# R2.  a,d:   striped with specified stripes
+# R3.  a,e:   NA
+# R4.  a,d,e: NA
+#
+# R5.  b:     mirror with default mirrors
+# R6.  b,d:   NA
+# R7.  b,e:   mirror with specified mirrors
+# R8.  b,d,e: NA
+#
+# R9.  c:     raid<N> with default stripes/mirrors
+# R10. c,d:   raid<N> with specified stripes
+# R11. c,e:   raid<N> with specified mirrors
+# R12. c,d,e: raid10 with specified stripes and mirrors
+#
+# R13. d:     striped with specified stripes
+# R14. e:     mirror with specified mirrors   
+# R15. d,e:   raid10 with specified mirrors
+
+# R1,R2 (--type striped with or without --stripes)
 lvcreate --type striped --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
@@ -751,36 +775,45 @@ ID: lvcreate_striped
 DESC: Create a striped LV (also see lvcreate --stripes).
 FLAGS: SECONDARY_SYNTAX
 
+# R13 (just --stripes)
 lvcreate --stripes Number --size SizeMB VG
-OO: --type striped, --stripesize SizeKB, OO_LVCREATE
+OO: --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
 DESC: Create a striped LV (infers --type striped).
 
----
-
+# R5,R7 (--type mirror with or without --mirrors)
 lvcreate --type mirror --size SizeMB VG
-OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes Number, OO_LVCREATE
+OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize,
+--stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
 DESC: Create a mirror LV (also see --type raid1).
 FLAGS: SECONDARY_SYNTAX
 
+# R14 (just --mirrors)
 # alternate form of lvcreate --type raid1|mirror
 lvcreate --mirrors PNumber --size SizeMB VG
-OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
+OO: --mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
 DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
----
-
+# R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
-OO: OO_LVCREATE_RAID, OO_LVCREATE
+OO: --mirrors PNumber, --stripes Number, --stripesize SizeKB,
+--regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
 DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
 
+# R15 (--stripes and --mirrors which implies raid10)
+lvcreate --mirrors PNumber --stripes Number --size SizeMB VG
+OO: --stripesize SizeKB, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_raid_any
+DESC: Create a raid10 LV.
+
 ---
 
 # The LV created by these commands actually has type linear or striped,


