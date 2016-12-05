From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:30 +0000 (UTC)
Subject: master - debug: add missing backtrace
Message-ID: <20161205161530.A7F3B602B1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36b211b464a02cf054a838ccf9139379897cf973
Commit:        36b211b464a02cf054a838ccf9139379897cf973
Parent:        3331199cc9f4b3935bc531428f03fbf3bb017d4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 4 22:29:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

debug: add missing backtrace

---
 lib/metadata/lv.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4a9fed7..8f13f6b 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -255,7 +255,8 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 	if (!(status.info_ok = lv_info_with_seg_status(seg->lv->vg->cmd, seg, &status, 0, 0)))
 		goto_bad;
 
-	ret = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, &status);
+	if (!(ret = lvseg_kernel_discards_dup_with_info_and_seg_status(mem, &status)))
+		stack;
 bad:
 	dm_pool_destroy(status.seg_status.mem);
 


