From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:07:58 -0400
Subject: 2018-06-01-stable - pvresize: update message
Message-ID: <201806221307.w5MD7wAa019647@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0bfc946cb182a021bb7a74a11ec7ac51ad9a7b0
Commit:        e0bfc946cb182a021bb7a74a11ec7ac51ad9a7b0
Parent:        9546edeef90af11cd8d80fc586caf40aad3640a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 23:09:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:34:24 2018 +0200

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


