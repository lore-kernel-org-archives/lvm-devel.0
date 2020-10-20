From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:06 +0000 (GMT)
Subject: master - properties: fix data_usage typo
Message-ID: <20201020203406.D5E4E3861893@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58976ccc34f9c60471e630666417a1fcef4d9799
Commit:        58976ccc34f9c60471e630666417a1fcef4d9799
Parent:        d2bdad28d1d1ad337a6c876c235797dbf6907886
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 16 17:51:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:18 2020 +0200

properties: fix data_usage typo

Patch 4de6f58085c533c79ce2e0db6cdeb6ed06fe05f8 introduce typo,
we need to use data_usage.

Note: this code was used by lvmapp library and currently is unused.
---
 lib/report/properties.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index ef2888f50..c013152f2 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -168,7 +168,7 @@ static dm_percent_t _data_percent(const struct logical_volume *lv)
 		if (!lv_thin_pool_status(lv, 0, &thin_pool_status))
 			stack;
 		else {
-			percent = thin_pool_status->metadata_usage;
+			percent = thin_pool_status->data_usage;
 			dm_pool_destroy(thin_pool_status->mem);
 		}
 	}


