From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Feb 2022 00:03:12 +0000 (GMT)
Subject: main - clang: possible better compilation with musl c
Message-ID: <20220216000312.4C7FB3858C1F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4fd76de4b69f8e5e6d5afa03d54cb4b8986c4bcc
Commit:        4fd76de4b69f8e5e6d5afa03d54cb4b8986c4bcc
Parent:        d2e7a05573f54750d13c1154036ae2c67478539b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 16 00:48:49 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 16 01:00:36 2022 +0100

clang: possible better compilation with musl c

Try to help resolving reported compilation problem with
clang & musl C.
https://github.com/lvmteam/lvm2/issues/61
---
 libdaemon/server/daemon-server.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 88905a7dd..96cfc392e 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -18,6 +18,7 @@
 
 #include <dlfcn.h>
 #include <errno.h>
+#include <fcntl.h> /* help musl C */
 #include <pthread.h>
 #include <sys/file.h>
 #include <sys/stat.h>


