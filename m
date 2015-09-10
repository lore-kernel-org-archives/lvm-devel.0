From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:29:55 +0000 (UTC)
Subject: master - lib: when moving segtypes, move LV bits
Message-ID: <20150910152955.D0CAE60B43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1edb5676e3ee6f84a3451fcbfe5d5be0d349188
Commit:        e1edb5676e3ee6f84a3451fcbfe5d5be0d349188
Parent:        3670f095c7d13a8052b129b3a264bb5a06e8b26e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 15:08:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:25:28 2015 +0200

lib: when moving segtypes, move LV bits

When we insert layer we also move status flag-bits for certain LV types,
so internal volume_group structure remains consistent.
(Perhaps it's misuse of 'insert_layer' function and we should have
another similar function for this.)

Basically we aim to maintain the same state as after reading fresh
metadata out of volume group.

Currently we when i.e. cache  'raid' LV - this should transfer 'raidLV' flag
to  _corigin LV and cache is no longer a raid.

TODO: bits for stacked devices needs more exact rules.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 184eb19..3119f12 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  When layering LV, move LV flags with segments.
   Ignore persistent cache if configuration changed. (2.02.127)
   Fix devices/filter to be applied before disk-accessing filters. (2.02.112)
   Make tags only when requested via 'make tags'.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 832a190..7412da7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6254,6 +6254,7 @@ int move_lv_segments(struct logical_volume *lv_to,
 		     struct logical_volume *lv_from,
 		     uint64_t set_status, uint64_t reset_status)
 {
+	const uint64_t MOVE_BITS = (RAID | MIRROR | THIN_VOLUME);
 	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv_to->segments)
@@ -6271,6 +6272,16 @@ int move_lv_segments(struct logical_volume *lv_to,
 		seg->status |= set_status;
 	}
 
+	/*
+	 * Move LV status bits for selected types with their segments
+	 * i.e. when inserting layer to cache LV, we move raid segments
+	 * to a new place, thus 'raid' LV property now belongs to this LV.
+	 *
+	 * Bits should match to those which appears after read from disk.
+	 */
+	lv_to->status |= lv_from->status & MOVE_BITS;
+	lv_from->status &= ~MOVE_BITS;
+
 	lv_to->le_count = lv_from->le_count;
 	lv_to->size = lv_from->size;
 


