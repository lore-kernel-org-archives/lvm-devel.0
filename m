From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:01 +0000 (UTC)
Subject: dev-mornfall-activate - mirror: implement check for remotely active LV
Message-ID: <20130604192801.01A7D60F1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31f3274ed8a81cbf6c25c7bc6307e58894f436a9
Commit:        31f3274ed8a81cbf6c25c7bc6307e58894f436a9
Parent:        e5baaf4ac9f2de39558b23606432ebeed483c99a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 19:10:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:42:31 2013 +0200

mirror: implement check for remotely active LV

If the mirror is active exclusively and locally, then we may proceed.
---
 lib/metadata/mirror.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f23bee3..f4f7b66 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2065,10 +2065,11 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (vg_is_clustered(lv->vg)) {
-		/* FIXME: review check of lv_is_active_remotely */
 		/* FIXME: move this test out of this function */
 		/* Skip test for pvmove mirrors, it can use local mirror */
 		if (!(lv->status & (PVMOVE | LOCKED)) &&
+		    lv_is_active(lv) &&
+		    !lv_is_active_exclusive_locally(lv) && /* lv_is_active_remotely */
 		    !_cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;


