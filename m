From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Dec 2017 16:21:36 -0500
Subject: master - lvmlockd: clear coverity complaint
Message-ID: <201712182121.vBILLae4000478@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f9ae846b89a2963a4ca72cfa0281aab0bedcc02
Commit:        3f9ae846b89a2963a4ca72cfa0281aab0bedcc02
Parent:        81be333e9fcf1f73b23318a9b3e9c366bf1a6cd2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 18 15:19:17 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 18 15:19:17 2017 -0600

lvmlockd: clear coverity complaint

from previous coverity fix, it's never happy.
---
 lib/locking/lvmlockd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 0365797..a4684b4 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2148,7 +2148,7 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
 			  const char *def_mode, uint32_t flags)
 {
-	struct logical_volume *pool_lv;
+	struct logical_volume *pool_lv = NULL;
 
 	if (lv_is_thin_volume(lv)) {
 		struct lv_segment *pool_seg = first_seg(lv);


