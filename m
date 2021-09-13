From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:11 +0000 (GMT)
Subject: main - cov: keep 64bit arithmetic
Message-ID: <20210913103611.7E03C3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ce8db8b889cbebdfe13aa394f5b6a9a9d00e25c
Commit:        3ce8db8b889cbebdfe13aa394f5b6a9a9d00e25c
Parent:        a7258ae39421f60c41f9ec79242f31b468a7460e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 22:35:11 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: keep 64bit arithmetic

Highly unlikely this case will ever need 64bit math, but just in case,
keep the expression as 64bit.
---
 lib/report/report.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 222d3f4b6..0fd0f30ac 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2342,7 +2342,7 @@ static int _lv_size_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint64_t size = lv->le_count;
 
 	if (seg && !lv_is_raid_image(lv))
-		size -= seg->reshape_len * (seg->area_count > 2 ? (seg->area_count - seg->segtype->parity_devs) : 1);
+		size -= (uint64_t) seg->reshape_len * (seg->area_count > 2 ? (seg->area_count - seg->segtype->parity_devs) : 1);
 
 	size *= lv->vg->extent_size;
 


