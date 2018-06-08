From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:48 -0400
Subject: master - pvresize: update message
Message-ID: <201806081238.w58Ccma9006040@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f5f8382ae09e3ba95486903cf86b29641a0023d
Commit:        1f5f8382ae09e3ba95486903cf86b29641a0023d
Parent:        fb171edd4520a91012eb6ce6652c241609f5f761
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 23:09:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:36:59 2018 +0200

pvresize: update message

There is always at least PV header update even if the size
of PV remains same (so it's not really resized).
Try to make it a slightly less confusing.
---
 tools/pvresize.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/pvresize.c b/tools/pvresize.c
index 8a65952..e951f11 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -96,7 +96,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvresize_single);
 
-	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
+	log_print_unless_silent("%d physical volume(s) resized or updated / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);
 out:
 	destroy_processing_handle(cmd, handle);


