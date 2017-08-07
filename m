From: David Teigland <teigland@sourceware.org>
Date: Mon, 7 Aug 2017 11:54:01 -0400
Subject: master - lvmlockd: global name doesn't apply to sanlock
Message-ID: <201708071554.v77Fs1sN023315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ecb5817c7e08a9a95a0172386af61ba3715948d
Commit:        8ecb5817c7e08a9a95a0172386af61ba3715948d
Parent:        568c7ed6f1a1df23b9843a54b0bc53816ac5f621
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 7 10:43:28 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 7 10:46:03 2017 -0500

lvmlockd: global name doesn't apply to sanlock

When adopting locks, we shouldn't skip the special
dlm global lockspace name when using sanlock.
---
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 5f08bbf..01259c0 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -5263,7 +5263,7 @@ static void adopt_locks(void)
 	list_for_each_entry_safe(ls1, l1safe, &ls_found, list) {
 
 		/* The dlm global lockspace is special and doesn't match a VG. */
-		if (!strcmp(ls1->name, gl_lsname_dlm)) {
+		if ((ls1->lm_type == LD_LM_DLM) && !strcmp(ls1->name, gl_lsname_dlm)) {
 			list_del(&ls1->list);
 			free(ls1);
 			continue;


