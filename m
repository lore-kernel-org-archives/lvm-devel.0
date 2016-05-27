From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 15:26:32 +0000 (UTC)
Subject: master - snapshot: for invalid snapshot show 100%
Message-ID: <20160527152632.2D9F860910@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88eeb004e9d34635221d45619723518a71ac2ccc
Commit:        88eeb004e9d34635221d45619723518a71ac2ccc
Parent:        43dfc2011c8955550e9e7b2fe0de78b452921326
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 27 17:16:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 17:25:37 2016 +0200

snapshot: for invalid snapshot show 100%

Recent commit 92eba53a797a011d1ce6fbd7bef88eab41af2072 started to report
empty "" data usage of invalid snapshot, restore 100% to be shown.
---
 lib/metadata/lv.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d67caa2..06f47f4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -380,8 +380,10 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 		}
 		break;
 	case SEG_STATUS_SNAPSHOT:
-		if (s->snapshot->invalid || s->snapshot->merge_failed)
+		if (s->snapshot->merge_failed)
 			p = DM_PERCENT_INVALID;
+		else if (s->snapshot->invalid)
+			p = DM_PERCENT_100; /* Shown as 100% full */
 		else if (s->snapshot->has_metadata_sectors &&
 			 (s->snapshot->used_sectors == s->snapshot->metadata_sectors))
 			p = DM_PERCENT_0;


