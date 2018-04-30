From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Apr 2018 14:03:36 -0400
Subject: master - clvmd: keep old saved_vg if it matches new
Message-ID: <201804301803.w3UI3aaF026932@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89935ace29bd2097467201546e9211ebed23c4bc
Commit:        89935ace29bd2097467201546e9211ebed23c4bc
Parent:        39f24a169c7cdec5e927a20aacb774e88407d31a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 30 13:00:05 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 30 13:03:15 2018 -0500

clvmd: keep old saved_vg if it matches new

There is no need to release the old saved_vg
if it matches the new version.
---
 lib/cache/lvmcache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index bd92055..cb19030 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -360,7 +360,8 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 		/* Do we need to actually set saved_vg_old to match saved_vg_new?
 		 * By just dropping old, we force a subsequent request for old to
 		 * reread it rather than just using new. */
-		if (vginfo->saved_vg_old) {
+
+		if (vginfo->saved_vg_old && (vginfo->saved_vg_old < vg->seqno)) {
 			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
 			_saved_vg_free(vginfo, 1, 0);
 		}
@@ -425,7 +426,8 @@ struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
 		/* Do we need to actually set saved_vg_old to match saved_vg_new?
 		 * By just dropping old, we force a subsequent request for old to
 		 * reread it rather than just using new. */
-		if (vginfo->saved_vg_old) {
+
+		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
 			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
 			_saved_vg_free(vginfo, 1, 0);
 		}


