From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:23 +0000 (UTC)
Subject: master - cleanup: add extra internal error
Message-ID: <20130615221623.8C2CB60D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02405219424619a56e7e3a3619e157f942e4fdb4
Commit:        02405219424619a56e7e3a3619e157f942e4fdb4
Parent:        a040dd8cfb8828e07a4df00117d89173562ab8be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 09:51:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:32 2013 +0200

cleanup: add extra internal error

Ensure the target line will work only with segment with pool.
---
 lib/thin/thin.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d1ffd27..116b7e1 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -493,6 +493,11 @@ static int _thin_add_target_line(struct dev_manager *dm,
 	char *pool_dlid, *external_dlid;
 	uint32_t device_id = seg->device_id;
 
+	if (!seg->pool_lv) {
+		log_error(INTERNAL_ERROR "Segment %s has no pool.",
+			  seg->lv->name);
+		return 0;
+	}
 	if (!(pool_dlid = build_dm_uuid(mem, seg->pool_lv->lvid.s, lv_layer(seg->pool_lv)))) {
 		log_error("Failed to build uuid for pool LV %s.",
 			  seg->pool_lv->name);


