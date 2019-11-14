From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:58 -0500
Subject: master - dmeventd: vdo plugin link lvm library
Message-ID: <19774.119111412075601497@us-mta-407.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbabdf2fca6131660cfb5525ed9edb3f7a41525a
Commit:        cbabdf2fca6131660cfb5525ed9edb3f7a41525a
Parent:        1da5fd822665e385415ffdf4a0e43e46c6fd7ba5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:52:05 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

dmeventd: vdo plugin link lvm library

Since we fixed linking of proper version of 'libdevmapper' with
linking lvm2 plugin correctly - we already have correct function
available linked with internal lvm library.
So drop unneeded include of parsing function.
---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index 9d267eb..7c4ec47 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -16,9 +16,6 @@
 #include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 
-/* Use parser from new device_mapper library */
-#include "device_mapper/vdo/status.c"
-
 #include <sys/wait.h>
 #include <stdarg.h>
 



