From: Milan Broz <mbroz@redhat.com>
Date: Tue,  7 Jun 2011 18:16:26 +0200
Subject: [PATCH] Validate mirror segments size
Message-ID: <1307463386-25210-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently some operation with striped mirrors lead
to corrupted metadata, this patch just add detection of such
situation.

Example:
# lvcreate -i2 -l10 -n lvs vg_test
# lvconvert -m1 vg_test/lvs

# lvreduce -f -l1 vg_test/lvs
  Reducing logical volume lvs to 4.00 MiB
  Segment extent reduction 9not divisible by #stripes 2
  Logical volume lvs successfully resized

# lvremove vg_test/lvs
  Segment extent reduction 1not divisible by #stripes 2
  LV segment lvs:0-4294967295 is incorrectly listed as being used by LV lvs_mimage_0
  Internal error: LV segments corrupted in lvs_mimage_0.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/merge.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 3b8895c..8de9ef4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -204,6 +204,16 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					inc_error_count;
 				}
 			}
+
+			if (complete_vg && seg_is_mirrored(seg) &&
+			    seg_type(seg, s) == AREA_LV &&
+			    seg_lv(seg, s)->le_count != seg->area_len) {
+				log_error("LV %s: mirrored LV segment %u has "
+					  "wrong size %u (should be %u).",
+					  lv->name, s, seg_lv(seg, s)->le_count,
+					  seg->area_len);
+				inc_error_count;
+			}
 		}
 
 		le += seg->len;
-- 
1.7.5.3


