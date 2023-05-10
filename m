From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2023 14:22:29 +0000 (GMT)
Subject: main - cov: remove unneeded header file inclusion
Message-ID: <20230510142229.91E653853831@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc7c41abbdb51a1e6c60c4a79aa56fe40ab7937a
Commit:        cc7c41abbdb51a1e6c60c4a79aa56fe40ab7937a
Parent:        7b52a663a6436581cfacd9212929db551a00920f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 12:55:38 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:27:48 2023 +0200

cov: remove unneeded header file inclusion

---
 lib/label/label.c | 1 -
 tools/pvscan.c    | 1 -
 2 files changed, 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 330089f1a..4b1362cf2 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -27,7 +27,6 @@
 #include "lib/format_text/layout.h"
 #include "lib/device/device_id.h"
 #include "lib/device/online.h"
-#include "lib/filters/filter.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8f51a0b42..058e8b658 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -19,7 +19,6 @@
 #include "lib/metadata/metadata.h"
 #include "lib/label/hints.h"
 #include "lib/device/online.h"
-#include "lib/filters/filter.h"
 
 #include <dirent.h>
 

