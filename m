From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 19:46:33 -0500
Subject: master - tests: prefer internal header
Message-ID: <201811170046.wAH0kXMU025233@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4021e88a31a440e64992742be76367f98fbc9400
Commit:        4021e88a31a440e64992742be76367f98fbc9400
Parent:        188bedf8de0c60a2269f76d99262c8892c5a2143
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 17 01:38:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 01:40:29 2018 +0100

tests: prefer internal header

Although we primarily want to check externally used libdevmapper
library,   out internal  all.h is still keeping all symbols
as the original library has - so for simpler compilation keep
using this private copy for defining needed symbols.
---
 test/lib/dmsecuretest.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/dmsecuretest.c b/test/lib/dmsecuretest.c
index 00d1e70..2ab7f81 100644
--- a/test/lib/dmsecuretest.c
+++ b/test/lib/dmsecuretest.c
@@ -10,7 +10,7 @@
  *
  */
 
-#include "libdevmapper.h"
+#include "device_mapper/all.h"
 
 #include <unistd.h>
 #include <signal.h>


