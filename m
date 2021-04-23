From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:01 +0000 (GMT)
Subject: main - clang: avoid possible use-after-free
Message-ID: <20210423210601.ED584394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51fd232b8eb2613a198b049d44688ea2422b248a
Commit:        51fd232b8eb2613a198b049d44688ea2422b248a
Parent:        21bdd0a3597eaa138906bc467f6749e70bc60e78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 22:08:57 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

clang: avoid possible use-after-free

If the 'act' has been already processed by add_client_result()
it could have been possibly release - so avoid accessin 'act->'
afterward and go for next item directly.
---
 daemons/lvmlockd/lvmlockd-core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index cd8485bb0..238ec718b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1800,9 +1800,7 @@ static void res_process(struct lockspace *ls, struct resource *r,
 			act->result = -EINVAL;
 			list_del(&act->list);
 			add_client_result(act);
-		}
-
-		if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN) {
+		} else if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN) {
 			rv = res_unlock(ls, r, act);
 
 			if (rv == -ENOENT && (act->flags & LD_AF_UNLOCK_CANCEL))


