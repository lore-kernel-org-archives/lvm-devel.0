From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 15:55:41 -0500
Subject: master - raid: cleanup _lv_set_image_lvs_start_les()
Message-ID: <201703072055.v27KtfWj008999@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ed11e919187fcc6d2a0ab192937e3cebed08592
Commit:        9ed11e919187fcc6d2a0ab192937e3cebed08592
Parent:        05aceaffbd184c6b5d892d92a6c4d9db182da8f8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 21:55:19 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 21:55:19 2017 +0100

raid: cleanup _lv_set_image_lvs_start_les()

Avoid second loop.
---
 lib/metadata/raid_manip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 1a4a860..40044f2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1302,12 +1302,11 @@ static int _lv_set_image_lvs_start_les(struct logical_volume *lv)
 			data_seg->le = le;
 			le += data_seg->len;
 		}
-	}
 
-	/* Try merging rimage sub LV segments _after_ adjusting start LEs */
-	for (s = 0; s < seg->area_count; s++)
+		/* Try merging rimage sub LV segments _after_ adjusting start LEs */
 		if (!lv_merge_segments(seg_lv(seg, s)))
 			return_0;
+	}
 
 	return 1;
 }


