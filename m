From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Feb 2017 15:46:18 -0500
Subject: master - commands: fixes for recent raid changes
Message-ID: <201702272046.v1RKkIaM020796@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d0df0c011f23095cf028c556db15b531ca91ea5
Commit:        8d0df0c011f23095cf028c556db15b531ca91ea5
Parent:        27384c52cf6a55ec7c8d64deecff2a81536193c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 24 16:43:05 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 27 14:44:00 2017 -0600

commands: fixes for recent raid changes

- Combine the equivalent lvconvert --type raid defs.
  (Two cmd defs must be different without relying
  on LV type, which are not known at the time the
  cmd def is matched.)

- Remove unused optional options from lvconvert --stripes,
  and lvconvert --stripesize.

- Use Number for --stripes_long val type.

- Combine the cmd def for raid reshape cleanup into the
  existing start_poll cmd def (they were duplicate defs).
  Calls into the raid code from a poll opertion will be
  added.
---
 tools/command-lines.in |   30 ++++++++++--------------------
 1 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index c3d684e..f8e0db7 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -338,19 +338,16 @@ ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1).
 RULE: all not lv_is_locked lv_is_pvmove
 
+# When LV is already raid, this changes the raid layout
+# (changing layout of raid0 and raid1 not allowed.)
+
 lvconvert --type raid LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
-DESC: Convert LV to raid.
-RULE: all not lv_is_locked lv_is_pvmove
-
-lvconvert --type raid LV_raid
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
-ID: lvconvert_raid_types
-DESC: Convert raid LV to different layout algorithm.
+DESC: Convert LV to raid or change raid layout.
 RULE: all not lv_is_locked lv_is_pvmove
-RULE: all not LV_raid0 LV_raid1
+RULE: LV_raid not LV_raid0 LV_raid1
 
 lvconvert --mirrors SNumber LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
@@ -359,8 +356,8 @@ ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.
 RULE: all not lv_is_locked lv_is_pvmove
 
-lvconvert --stripes_long SNumber LV_raid
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+lvconvert --stripes_long Number LV_raid
+OO: OO_LVCONVERT, --interval Number, --regionsize RegionSize, --stripesize SizeKB
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert raid LV to change number of stripe images.
@@ -368,7 +365,7 @@ RULE: all not lv_is_locked lv_is_pvmove
 RULE: all not LV_raid0 LV_raid1
 
 lvconvert --stripesize SizeKB LV_raid
-OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OO: OO_LVCONVERT, --interval Number, --regionsize RegionSize
 ID: lvconvert_raid_types
 DESC: Convert raid LV to change the stripe size.
 RULE: all not lv_is_locked lv_is_pvmove
@@ -381,13 +378,6 @@ DESC: Change the region size of an LV.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all not LV_raid0
 
-lvconvert LV_mirror_raid
-OO: OO_LVCONVERT
-ID: lvconvert_raid_types
-DESC: Remove out-of-place reshape space
-RULE: all not lv_is_locked lv_is_pvmove
-RULE: all not LV_raid0 LV_raid1
-
 ---
 
 # lvconvert raid-related utilities
@@ -677,7 +667,7 @@ RULE: all not lv_is_locked lv_is_pvmove
 # This command just (re)starts the polling process on the LV
 # to continue a previous conversion.
 
-lvconvert --startpoll LV_mirror
+lvconvert --startpoll LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
 DESC: Poll LV to continue conversion.
@@ -685,7 +675,7 @@ RULE: all and lv_is_converting
 
 # alternate form of lvconvert --startpoll, this is only kept
 # for compat since this was how it used to be done.
-lvconvert LV_mirror
+lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
 DESC: Poll LV to continue conversion.


