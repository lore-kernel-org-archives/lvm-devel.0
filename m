From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:40 -0400
Subject: master - bcache: do not use libdm header files
Message-ID: <201805121626.w4CGQeJP008363@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac768a9d2baca83bd9043d4d36f8e436894d29f7
Commit:        ac768a9d2baca83bd9043d4d36f8e436894d29f7
Parent:        83e362cd32e4648fd386401bbdcd72374731dd67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 11 18:41:44 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

bcache: do not use libdm header files

Logging for libdm differs from lvm logging - keep using consisten
logging function calls.
---
 lib/device/bcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9085d87..f8ed7af 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -15,7 +15,7 @@
 #define _GNU_SOURCE
 
 #include "bcache.h"
-#include "dm-logging.h"
+#include "lvm-logging.h"
 #include "log.h"
 
 #include <errno.h>


