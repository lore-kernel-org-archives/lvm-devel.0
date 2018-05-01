From: David Teigland <teigland@sourceware.org>
Date: Tue, 1 May 2018 10:07:21 -0400
Subject: master - lvmcache: fix typo in lvmcache_get_saved_vg
Message-ID: <201805011407.w41E7LtU009364@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a418f88b76d6b67c58af6b8a7d75db29106ff0e1
Commit:        a418f88b76d6b67c58af6b8a7d75db29106ff0e1
Parent:        3ea862bdfc036f6e5ce08ba01eb706d1d10638cd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 1 09:06:04 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 1 09:06:57 2018 -0500

lvmcache: fix typo in lvmcache_get_saved_vg

---
 lib/cache/lvmcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8ba8b3c..9023bcc 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -359,7 +359,7 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 		 * By just dropping old, we force a subsequent request for old to
 		 * reread it rather than just using new. */
 
-		if (vginfo->saved_vg_old && (vginfo->saved_vg_old < vg->seqno)) {
+		if (vginfo->saved_vg_old && (vginfo->saved_vg_old->seqno < vg->seqno)) {
 			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
 			_saved_vg_free(vginfo, 1, 0);
 		}


