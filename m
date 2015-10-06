From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Oct 2015 13:25:14 +0000 (UTC)
Subject: master - cleanup: fix compiler warning
Message-ID: <20151006132514.F214260F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2506275c3b5ec7db8c76ef7fdb07d4f3083a3684
Commit:        2506275c3b5ec7db8c76ef7fdb07d4f3083a3684
Parent:        5f7a94a03e8ff61213844fd510e8af127475b501
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 3 22:10:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 6 14:57:30 2015 +0200

cleanup: fix compiler warning

---
 lib/cache/lvmetad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index db15866..20d2001 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -53,8 +53,8 @@ static int _log_debug_inequality(const char *name, struct dm_config_node *a, str
 					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %s / %s",
 							  name, a->key, b->key, av->v.str, bv->v.str);
 				else if (a->v->type == DM_CFG_INT && b->v->type == DM_CFG_INT)
-					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %li / %li",
-							  name, a->key, b->key, (int64_t)av->v.i, (int64_t)bv->v.i);
+					log_debug_lvmetad("VG %s metadata inequality at %s / %s: " FMTi64 " / " FMTi64,
+							  name, a->key, b->key, av->v.i, bv->v.i);
 				else
 					log_debug_lvmetad("VG %s metadata inequality at %s / %s: type %d / type %d",
 							  name, a->key, b->key, av->type, bv->type);


