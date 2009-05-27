From: Milan Broz <mbroz@redhat.com>
Date: Wed, 27 May 2009 13:08:46 +0200
Subject: [PATCH] Propagate inability to allocate extents for log on provided area.
Message-ID: <4A1D1F3E.5030809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Propagate inability to allocate extents for log on provided area.

Easily reproducible with (bug 502761)
  vgcreate -s 1k ..
  lvcreate -m1 ... <leg1_dev> <leg2_dev> <log_dev>:0-0
Here it needs 2 extents for log but only one is provided.

Currently code fails on assert inside consume_pv_area, now
it should print proper error message.
"Insufficient extents for log allocation for logical volume"

(Patch is more workaround than real fix, the allocation code is not too
user friendly regarding error reporting but it waits for some rewrite:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index eeb4710..7a58a80 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -766,7 +766,14 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
 		ah->log_area.len = mirror_log_extents(ah->log_region_size,
 						      pv_pe_size(log_area->map->pv),
 						      area_len);
-		consume_pv_area(log_area, ah->log_area.len);
+		/*
+		 * Provided log area is too small,
+		 * set zero length to notify layer above
+		 */
+		if (ah->log_area.len > log_area->count)
+			ah->log_area.len = 0;
+		else
+			consume_pv_area(log_area, ah->log_area.len);
 	}
 
 	*ix += area_len * ah->area_multiple;



