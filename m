From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:50 +0000 (UTC)
Subject: master - lv_status: track layered device
Message-ID: <20150114135450.8D34C60C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b7ccf835bf90b6cb75cdeb6615163835a988107
Commit:        0b7ccf835bf90b6cb75cdeb6615163835a988107
Parent:        d0f26440eed53fd34faf2773a9a7faf6deaf7d66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 12:52:40 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:50:08 2015 +0100

lv_status: track layered device

For info of i.e. thin-pool we need layered device.
Needs some more thinking about proper interface here.
For now it's usable for cache and thin-pool.
---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d1d1104..94ad9e2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -705,7 +705,7 @@ int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
 	if (!activation())
 		return 0;
 
-	return _lv_info(cmd, lv_seg->lv, 0, NULL, lv_seg, lv_seg_status, 0, 0);
+	return _lv_info(cmd, lv_seg->lv, 1, NULL, lv_seg, lv_seg_status, 0, 0);
 }
 
 /*


