From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:21 +0000 (UTC)
Subject: master - thin: skip detach preload from pools
Message-ID: <20151124103321.70F2E60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e50e5f0b4074bbeb093f1fba334076be3f59f3f
Commit:        5e50e5f0b4074bbeb093f1fba334076be3f59f3f
Parent:        6d6c233768e2a9c3bd9fd13e113e2a890c18b2cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 22 23:04:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:42:59 2015 +0100

thin: skip detach preload from pools

lv preload for detached LVs started to be used also
for various other types which just happens to pass through
weak if() condition.

TODO: find here better solution to rather explicitly check
for types we really need to preload.
---
 lib/activate/activate.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6a6a952..c30a7ac 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1778,8 +1778,11 @@ static int _preload_detached_lv(struct logical_volume *lv, void *data)
 			return_0;
 	}
 
+	/* FIXME: condition here should be far more limiting to really
+	 *        detect detached LVs */
 	if ((lv_pre = find_lv(detached->lv_pre->vg, lv->name))) {
 		if (lv_is_visible(lv_pre) && lv_is_active(lv) &&
+		    !lv_is_pool(lv) &&
 		    (!lv_is_cow(lv) || !lv_is_cow(lv_pre)) &&
 		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
 			return_0;


