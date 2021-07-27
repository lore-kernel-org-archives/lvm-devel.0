From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:36 +0000 (GMT)
Subject: main - cov: raid: no more checks with missing areas
Message-ID: <20210727225036.7EC30385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4b49dae1eb982e36e748fa8e1fc2af59025c9c7
Commit:        f4b49dae1eb982e36e748fa8e1fc2af59025c9c7
Parent:        b2db01b530e995a80abe3379019503a8cae72b10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 17:01:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: raid: no more checks with missing areas

Since ->areas is directly dereferenced we need to stop
validation right here.
---
 lib/metadata/merge.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f29cf64ec..8eff74297 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -270,8 +270,10 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	if (!seg->area_count)
 		raid_seg_error("zero area count");
 
-	if (!seg->areas)
+	if (!seg->areas) {
 		raid_seg_error("zero areas");
+		return;
+	}
 
 	if (seg->extents_copied > seg->len)
 		raid_seg_error_val("extents_copied too large", seg->extents_copied);


