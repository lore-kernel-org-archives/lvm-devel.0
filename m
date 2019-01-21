From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:30 -0500
Subject: master - vdo: estimate virtual size after resize
Message-ID: <201901211155.x0LBtUHu024489@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca72d19691683266f14dac7ae2eac755eeda6586
Commit:        ca72d19691683266f14dac7ae2eac755eeda6586
Parent:        ab031d673d7c75ca1217864dffc3c8e79e97c8f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 16 15:35:07 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: estimate virtual size after resize

---
 lib/metadata/lv_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index def1c03..9ef568c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3349,6 +3349,10 @@ static int _lv_add_vdo_segment(struct logical_volume *lv, uint64_t status,
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
+	if (seg_lv(seg, 0) &&
+	    !update_vdo_pool_virtual_size(first_seg(seg_lv(seg, 0))))
+		return_0;
+
 	return 1;
 }
 


