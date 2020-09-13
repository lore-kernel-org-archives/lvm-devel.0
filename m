From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:41 +0000 (GMT)
Subject: master - headers: remove unused headers
Message-ID: <20200913221641.A8AA53865491@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c285bf2f3794629161e55111f9a076cb9852dd26
Commit:        c285bf2f3794629161e55111f9a076cb9852dd26
Parent:        27383a4b3d621e6c2497c8b1f55e2a700a6ef39a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 13 11:32:29 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

headers: remove unused headers

---
 tools/lvmcmdlib.c  | 1 -
 tools/lvmcmdline.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 695d4dda6..aa85c9ccd 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -21,7 +21,6 @@
 
 #include "tools/lvm2cmd.h"
 
-#include <signal.h>
 #include <sys/stat.h>
 #include <time.h>
 #include <sys/resource.h>
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7cf4e3ff0..8dd38e51d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -23,7 +23,6 @@
 #include "stub.h"
 #include "lib/misc/last-path-component.h"
 
-#include <signal.h>
 #include <sys/stat.h>
 #include <time.h>
 #include <sys/resource.h>


