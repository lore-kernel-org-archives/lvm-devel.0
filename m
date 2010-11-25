From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:17 +0100
Subject: [PATCH 13/29] Put some FIXME warnings in lvmcache_update_vg processing
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <24b600ce0d709f07f4628826b950770ce6190dc6.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's not clear how this code is supposed to work.
For now we never set INCONSISTENT_VG flag - so marking expression with
big FIXME as it always gives true.
Remove extra paramater from lvmcache_update_vg call - as it effectively
produced always 'false' - so reverting to previous version - where it has been
possible to get also 'true' - use case is probably only in cluster
environment - some testcase is needed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 743d633..fd5d024 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2679,6 +2679,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * the missing PV logic below.
 	 */
 	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
+	    /* FIXME: Expression is always TRUE - as we never set INCONSISTENT_VG! */
 	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
 		if (!(correct_vg->status & INCONSISTENT_VG))
 			*consistent = 1;
@@ -2935,8 +2936,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * If there is no precommitted metadata, committed metadata
 	 * is read and stored in the cache even if use_precommitted is set
 	 */
-	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
-			   (inconsistent ? INCONSISTENT_VG : 0));
+	/* FIXME: How to handle INCONSISTENT_VG? */
+	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
-- 
1.7.3.2


