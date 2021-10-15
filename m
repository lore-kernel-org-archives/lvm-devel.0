From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:23 +0000 (GMT)
Subject: main - cov: do not drop already known error state
Message-ID: <20211015214223.EDED63858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65ba4964df27d2d3f308d2f378e814290ba6d7bb
Commit:        65ba4964df27d2d3f308d2f378e814290ba6d7bb
Parent:        e7b5f490c53368b9591fe8c5561de4371207f882
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 14:46:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:40:56 2021 +0200

cov: do not drop already known error state

Do not try to 'discover' another error state, when ENOMEM
is already detected.
---
 daemons/lvmlockd/lvmlockd-core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c1785a764..175f59331 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3016,9 +3016,7 @@ static int add_lockspace_thread(const char *ls_name,
 				!alloc_and_copy_pvs_path(&ls2->pvs, &ls->pvs)) {
 			log_debug("add_lockspace_thread %s fails to allocate pvs", ls->name);
 			rv = -ENOMEM;
-		}
-
-		if (ls2->thread_stop) {
+		} else if (ls2->thread_stop) {
 			log_debug("add_lockspace_thread %s exists and stopping", ls->name);
 			rv = -EAGAIN;
 		} else if (!ls2->create_fail && !ls2->create_done) {


