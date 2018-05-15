From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:42 -0400
Subject: master - lvmapp: do not unlock not locked VGs
Message-ID: <201805152005.w4FK5gHZ001507@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb0aca86f847fc13d9a9e4cc933085644e5ce29f
Commit:        fb0aca86f847fc13d9a9e4cc933085644e5ce29f
Parent:        99cd7108d3c589fb8ebbd636c98881cfee30e868
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:58:40 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

lvmapp: do not unlock not locked VGs

After recent changes this seems to give some help, explore more...
---
 liblvm/lvm_vg.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 616c78f..ee6fa4e 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -186,6 +186,8 @@ int lvm_vg_close(vg_t vg)
 	struct saved_env e = store_user_env(vg->cmd);
 	if (vg_read_error(vg) == FAILED_LOCKING)
 		release_vg(vg);
+	else if (!lvmcache_vgname_is_locked(vg->name))
+		release_vg(vg);
 	else
 		unlock_and_release_vg(vg->cmd, vg, vg->name);
 	restore_user_env(&e);


