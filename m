From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:36 +0000 (UTC)
Subject: master - headers: add headers for musl libc
Message-ID: <20130205134736.92140A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3b8f270eac7314767e9098ef28e2f8b89fbf296
Commit:        d3b8f270eac7314767e9098ef28e2f8b89fbf296
Parent:        7cd25062acc5c54959e892381600257372ef071f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 09:33:30 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:27:25 2013 +0100

headers: add headers for musl libc

On glibc, those are erroneously (namespace pollution) pulled in via
other headers. this doesn't work with conformant libcs (musl libc in
this case), we simply need to include all needed headers.

Signed-Off-By: John Spencer <maillist-lvm@barfooze.de>
---
 daemons/dmeventd/dmeventd.c                        |    1 +
 libdm/mm/pool-fast.c                               |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 55b940f..06c0c92 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -37,6 +37,7 @@
 #include <unistd.h>
 #include <signal.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
+#include <fcntl.h>
 
 #ifdef linux
 /*
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 61e076a..0e13416 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -18,6 +18,7 @@
 #endif
 
 #include "dmlib.h"
+#include <stddef.h>
 #include <malloc.h>
 
 struct chunk {
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index dfd6fc4..6fc2865 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -19,6 +19,7 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
+#include <limits.h>		/* for PATH_MAX */
 #include "lvm2app.h"
 
 #define KMSG_DEV_PATH        "/dev/kmsg"


