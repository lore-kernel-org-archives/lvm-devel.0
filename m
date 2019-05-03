From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:24 -0400
Subject: master - build: fix compilation without lvmlockd
Message-ID: <201905031118.x43BIOwL028338@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a5ea681fb57cd4bb7ba9db50e57bf2ee4e9ed8c
Commit:        7a5ea681fb57cd4bb7ba9db50e57bf2ee4e9ed8c
Parent:        a520b3002c2f31f84324d2f59dd1e156bc45ec65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 12:35:22 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

build: fix compilation without lvmlockd

---
 lib/locking/lvmlockd.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 1738192..4393420 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -13,6 +13,7 @@
 
 #include "libdaemon/client/config-util.h"
 #include "libdaemon/client/daemon-client.h"
+#include "lib/metadata/metadata-exported.h" /* is_lockd_type() */
 
 #define LOCKD_SANLOCK_LV_NAME "lvmlock"
 
@@ -182,7 +183,7 @@ static inline int lockd_global_create(struct cmd_context *cmd, const char *def_m
 	return 1;
 }
 
-static inline int lockd_global(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
+static inline int lockd_global(struct cmd_context *cmd, const char *def_mode)
 {
 	return 1;
 }


