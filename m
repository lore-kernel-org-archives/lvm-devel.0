From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 15 Dec 2015 22:17:37 +0000 (UTC)
Subject: master - lvmlockd: update VG lock version earlier
Message-ID: <20151215221737.A25AE60E79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=124b490fe671fc53aef989b384c4a5a87c9ff6d0
Commit:        124b490fe671fc53aef989b384c4a5a87c9ff6d0
Parent:        796461a9125a8324a63be154fc998245617e5990
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 15 16:14:49 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 15 16:14:49 2015 -0600

lvmlockd: update VG lock version earlier

Have commands send lvmlockd the update message
in vg_write instead of vg_commit, so that it's
not done while LVs are suspended.  If the vg_write
is not committed, and the seqno sent to lvmlockd
is not used, then lvmlockd can detect this when
the next update uses the same seqno.
---
 daemons/lvmlockd/lvmlockd-core.c |   17 ++++++++++++++++-
 lib/metadata/metadata.c          |    4 ++--
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index e495d3b..efb0180 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1579,8 +1579,23 @@ static int res_update(struct lockspace *ls, struct resource *r,
 
 	if (act->flags & LD_AF_NEXT_VERSION)
 		lk->version = r->version + 1;
-	else
+	else {
+		if (r->version >= act->version) {
+			/*
+			 * This update is done from vg_write. If the metadata with
+			 * this seqno is not committed by vg_commit, then next
+			 * vg_write can use the same seqno, causing us to see no
+			 * increase in seqno here as expected.
+			 * FIXME: In this case, do something like setting the lvb
+			 * version to 0 to instead of the same seqno which will
+			 * force an invalidation on other hosts.  The next change
+			 * will return to using the seqno again.
+			 */
+			log_error("S %s R %s res_update cl %u old version %u new version %u too small",
+			  	  ls->name, r->name, act->client_id, r->version, act->version);
+		}
 		lk->version = act->version;
+	}
 
 	log_debug("S %s R %s res_update cl %u lk version to %u", ls->name, r->name, act->client_id, lk->version);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ae40906..a1d2e2b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3138,6 +3138,8 @@ int vg_write(struct volume_group *vg)
 	if (!(vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
 		return_0;
 
+	lockd_vg_update(vg);
+
 	return 1;
 }
 
@@ -3194,8 +3196,6 @@ int vg_commit(struct volume_group *vg)
 
 	cache_updated = _vg_commit_mdas(vg);
 
-	lockd_vg_update(vg);
-
 	if (cache_updated) {
 		/* Instruct remote nodes to upgrade cached metadata. */
 		if (!remote_commit_cached_metadata(vg))


