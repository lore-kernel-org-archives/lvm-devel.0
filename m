From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:23 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063223.EBC0360AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1784cc990e6941e93cfcf1204526cec75d287a89
Commit:        1784cc990e6941e93cfcf1204526cec75d287a89
Parent:        2d74de3f05d44b2ac5f651e49d29878731a114a1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 03:56:10 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Change:
- add missing raid1 <-> raid5 conversions to support
  linear <-> raid5 <-> raid0(_meta)/striped conversions
- rename related new takeover functions to
  _takeover_from_raid1_to_raid5 and _takeover_from_raid5_to_raid1,
  because a reshape to > 2 legs is only possible with
  raid5 layout

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c      |   13 +++++++++----
 lib/metadata/takeover_matrix.h |    8 ++++----
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index fc02d3d..40bc45e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5323,9 +5323,11 @@ static int _takeover_from_raid1_to_raid10(TAKEOVER_FN_ARGS)
 	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
 }
 
-static int _takeover_from_raid1_to_raid45(TAKEOVER_FN_ARGS)
+static int _takeover_from_raid1_to_raid5(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _takeover_upconvert_wrapper(lv, new_segtype, yes, force,
+					   first_seg(lv)->area_count /* unchanged new_image_count */,
+					   2 /* data_copies */, 0, 0, new_region_size, allocate_pvs);
 }
 
 static int _takeover_from_raid1_to_striped(TAKEOVER_FN_ARGS)
@@ -5357,9 +5359,12 @@ static int _takeover_from_raid45_to_raid0_meta(TAKEOVER_FN_ARGS)
 					     1 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
-static int _takeover_from_raid45_to_raid1(TAKEOVER_FN_ARGS)
+
+static int _takeover_from_raid5_to_raid1(TAKEOVER_FN_ARGS)
 {
-	return _takeover_unsupported_yet(lv, new_stripes, new_segtype);
+	return _takeover_downconvert_wrapper(lv, new_segtype, yes, force,
+					     first_seg(lv)->area_count,
+					     2 /* data_copies */, 0, 0, 0, allocate_pvs);
 }
 
 static int _takeover_from_raid45_to_raid54(TAKEOVER_FN_ARGS)
diff --git a/lib/metadata/takeover_matrix.h b/lib/metadata/takeover_matrix.h
index bb3e6cb..8ac2f75 100644
--- a/lib/metadata/takeover_matrix.h
+++ b/lib/metadata/takeover_matrix.h
@@ -58,13 +58,13 @@
 #define r1__r0m  _takeover_from_raid1_to_raid0_meta
 #define r1__r1   _takeover_from_raid1_to_raid1
 #define r1__r10  _takeover_from_raid1_to_raid10
-#define r1__r45  _takeover_from_raid1_to_raid45
+#define r1__r5   _takeover_from_raid1_to_raid5
 #define r1__str  _takeover_from_raid1_to_striped
 #define r45_lin  _takeover_from_raid45_to_linear
 #define r45_mir  _takeover_from_raid45_to_mirrored
 #define r45_r0   _takeover_from_raid45_to_raid0
 #define r45_r0m  _takeover_from_raid45_to_raid0_meta
-#define r45_r1   _takeover_from_raid45_to_raid1
+#define r5_r1    _takeover_from_raid5_to_raid1
 #define r45_r54  _takeover_from_raid45_to_raid54
 #define r45_r6   _takeover_from_raid45_to_raid6
 #define r45_str  _takeover_from_raid45_to_striped
@@ -109,8 +109,8 @@ static takeover_fn_t _takeover_fns[][11] = {
         /* mirror     */ { X      ,  X      ,  N      ,  mir_r0,  mir_r0m,  mir_r1,  mir_r45,  X     ,  mir_r10,  X      , X },
         /* raid0      */ { r0__lin,  r0__str,  r0__mir,  N     ,  r0__r0m,  r0__r1,  r0__r45,  r0__r6,  r0__r10,  X      , X },
         /* raid0_meta */ { r0m_lin,  r0m_str,  r0m_mir,  r0m_r0,  N      ,  r0m_r1,  r0m_r45,  r0m_r6,  r0m_r10,  X      , X },
-        /* raid1      */ { r1__lin,  r1__str,  r1__mir,  r1__r0,  r1__r0m,  r1__r1,  r1__r45,  X     ,  r1__r10,  X      , X },
-        /* raid4/5    */ { r45_lin,  r45_str,  r45_mir,  r45_r0,  r45_r0m,  r45_r1,  r45_r54,  r45_r6,  X      ,  X      , X },
+        /* raid1      */ { r1__lin,  r1__str,  r1__mir,  r1__r0,  r1__r0m,  r1__r1,  r1__r5,   X     ,  r1__r10,  X      , X },
+        /* raid4/5    */ { r45_lin,  r45_str,  r45_mir,  r45_r0,  r45_r0m,  r5_r1 ,  r45_r54,  r45_r6,  X      ,  X      , X },
         /* raid6      */ { X      ,  r6__str,  X      ,  r6__r0,  r6__r0m,  X     ,  r6__r45,  X     ,  X      ,  X      , X },
         /* raid10     */ { r10_lin,  r10_str,  r10_mir,  r10_r0,  r10_r0m,  r10_r1,  X      ,  X     ,  X      ,  X	 , X },
         /* raid01     */ // { X      ,  r01_str,  X      ,  X     ,  X      ,  X     ,  X      ,  X     ,  r01_r10,  r01_r01, X },


