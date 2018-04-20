From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:08 -0400
Subject: master - mirror: use vg mempool
Message-ID: <201804201102.w3KB28Ym031275@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d81e3f9b067f9eb44122a8637966bfa838716135
Commit:        d81e3f9b067f9eb44122a8637966bfa838716135
Parent:        05f954ee9b6339680c4430721a5c6bbc425fe315
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 23:12:57 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:16:14 2018 +0200

mirror: use vg mempool

Use vg mempool with mirror log metadata update.
---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index e09103d..8fcf94e 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -341,7 +341,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	/* Temporary tag mirror log for activation */
 	dm_list_iterate_items(sl, tagsl)
-		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
+		if (!str_list_add(log_lv->vg->vgmem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
 			return 0;
 		}


