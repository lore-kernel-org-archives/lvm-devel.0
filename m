From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  4 Dec 2009 15:05:58 +0100
Subject: [PATCH 17/22] Replicator: no crash lvresize if area_count is 0
In-Reply-To: <cover.1259934415.git.zkabelac@redhat.com>
References: <cover.1259934415.git.zkabelac@redhat.com>
Message-ID: <31e78db91cb13ad5b43aa0d5be0c108dedacc9ec.1259934415.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently with replicator-dev LV we get area_count=0 for lvresize request.
The original reason needs to be exploread, meanwhile avoid crash,
but stopping processing if count is 0.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 99aa8f9..5f85261 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1369,6 +1369,11 @@ int lv_add_segment(struct alloc_handle *ah,
 		return 0;
 	}
 
+	if (!ah->area_count) {
+		log_error("Allocated areas are empty.");
+		return 0;
+	}
+
 	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
 				     num_areas, status,
 				     stripe_size, segtype,
-- 
1.6.5.3


