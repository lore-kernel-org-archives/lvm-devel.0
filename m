From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:09 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140430082809.A749E60D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62e8dd4f6ec73b6f94f66c3b14cdf3d80c06a2af
Commit:        62e8dd4f6ec73b6f94f66c3b14cdf3d80c06a2af
Parent:        cbdf63fdd21216af78077ae2d02ac307a3deec0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 20:14:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:30 2014 +0200

cleanup: indent

---
 lib/metadata/lv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 54306a2..4dbcb20 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -154,8 +154,7 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	else if (!seg_monitored(segm) || (segm->status & PVMOVE))
 		s = "not monitored";
 	else if (lv_info(seg->lv->vg->cmd, seg->lv, 1, &info, 0, 0) && info.exists) {
-		monitored = segm->segtype->ops->
-			target_monitored((struct lv_segment*)segm, &pending);
+		monitored = segm->segtype->ops->target_monitored(segm, &pending);
 		if (pending)
 			s = "pending";
 		else


