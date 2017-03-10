From: David Teigland <teigland@sourceware.org>
Date: Fri, 10 Mar 2017 15:49:17 -0500
Subject: master - commands: fix lvconvert options for mirrors/stripes
Message-ID: <201703102049.v2AKnHfK020385@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15682270f4557958d5e2994990534b652229857d
Commit:        15682270f4557958d5e2994990534b652229857d
Parent:        5d3e870946fecdc6deefbef41430ec561eed183a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 10 14:05:15 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 10 14:05:15 2017 -0600

commands: fix lvconvert options for mirrors/stripes

The LVCONVERT_RAID shortcut for including options ended
up including mirrors/stripes as optional opts in defs where
they were already required, or in defs where they would
not be used.  Remove the option set and specify in each
case only the options wanted.
---
 tools/command-lines.in |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index f87bf23..9651053 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -304,9 +304,6 @@ RULE: all not LV_thinpool LV_cachepool
 
 ---
 
-OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
---stripesize SizeKB, --regionsize RegionSize, --interval Number
-
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
@@ -323,21 +320,21 @@ OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
 # They are all routed into the core raid conversion code.
 
 lvconvert --type linear LV
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to linear.
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --type striped LV
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OO: --stripes_long Number, --stripesize SizeKB, --regionsize RegionSize, --interval Number, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to striped.
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --type mirror LV
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
+OO: --mirrors SNumber, --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1),
@@ -349,7 +346,7 @@ FLAGS: SECONDARY_SYNTAX
 # (changing layout of raid0 and raid1 not allowed.)
 
 lvconvert --type raid LV
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OO: --mirrors SNumber, --stripes_long Number, --stripesize SizeKB, --regionsize RegionSize, --interval Number, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid or change raid layout
@@ -357,7 +354,7 @@ DESC: (a specific raid level must be used, e.g. raid1).
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --mirrors SNumber LV
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
+OO: --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.


