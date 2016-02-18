From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 17:12:01 +0000 (UTC)
Subject: master - thin: fix test for nonexisting status
Message-ID: <20160218171201.9E94060ED8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42b394c1425c18fb236e82847c64258afd150ae6
Commit:        42b394c1425c18fb236e82847c64258afd150ae6
Parent:        bcf7f80791d8bcee20056fd371b7f1557d5c1649
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 18:09:49 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 18:11:29 2016 +0100

thin: fix test for nonexisting status

Check status has right type.
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index b96dcfc..ed6202c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3317,7 +3317,7 @@ static int _lvcheckneeded_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lv_is_thin_pool(lvdm->lv))
+	if (lv_is_thin_pool(lvdm->lv) && lvdm->seg_status.type == SEG_STATUS_THIN_POOL)
 		return _binary_disp(rh, mem, field, lvdm->seg_status.thin_pool->needs_check,
 				    GET_FIRST_RESERVED_NAME(lv_check_needed_y), private);
 


