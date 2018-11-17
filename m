From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 19:12:47 -0500
Subject: master - tests: correcting header file enclosure
Message-ID: <201811170012.wAH0ClJU020501@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=188bedf8de0c60a2269f76d99262c8892c5a2143
Commit:        188bedf8de0c60a2269f76d99262c8892c5a2143
Parent:        ea001426af94d07ba1e787b36a0c325e33c6a3d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 17 01:11:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 01:12:06 2018 +0100

tests: correcting header file enclosure

Use "" for internal header file.
---
 test/lib/dmsecuretest.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/dmsecuretest.c b/test/lib/dmsecuretest.c
index 0428fac..00d1e70 100644
--- a/test/lib/dmsecuretest.c
+++ b/test/lib/dmsecuretest.c
@@ -10,9 +10,10 @@
  *
  */
 
+#include "libdevmapper.h"
+
 #include <unistd.h>
 #include <signal.h>
-#include <libdevmapper.h>
 
 /* Comment out this define to get coredump instead of sleeping */
 #define SLEEP 1


