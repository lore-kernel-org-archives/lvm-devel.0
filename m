From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:33 -0500
Subject: master - cleanup: drop unused header
Message-ID: <201712041457.vB4EvXU3007096@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a22576b2d5b839f30d0dd7fb652920b303366f3
Commit:        2a22576b2d5b839f30d0dd7fb652920b303366f3
Parent:        e447d7ca5e178bc7b13d5aabaef3d160b4655f07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 1 22:58:47 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: drop unused header

DM_UUID_LEN is no longer needed.
---
 lib/activate/dev_manager.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5662090..c050f34 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -26,7 +26,6 @@
 #include "activate.h"
 #include "lvm-exec.h"
 #include "str_list.h"
-#include "dm-ioctl.h" /* for DM_UUID_LEN */
 
 #include <limits.h>
 #include <dirent.h>


