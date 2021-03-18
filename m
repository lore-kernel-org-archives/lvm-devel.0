From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:01 +0000 (GMT)
Subject: main - lvresize: support resize of stacked virtual LV
Message-ID: <20210318181501.37C5D3848011@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a73399b73305786b61c8dcc78a76d4319608561
Commit:        5a73399b73305786b61c8dcc78a76d4319608561
Parent:        adc238062d13949cbf3a0b20abf310ee3f132e7e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 13:14:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

lvresize: support resize of stacked virtual LV

Update the LV stack with the size also for virtual LVs.
---
 lib/metadata/lv_manip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3fff66b18..24a2816ef 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3554,8 +3554,8 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 		dm_list_add(&lv->segments, &seg->list);
 	}
 
-	lv->le_count += extents;
-	lv->size += (uint64_t) extents *lv->vg->extent_size;
+	if (!_setup_lv_size(lv, lv->le_count + extents))
+		return_0;
 
 	return 1;
 }


