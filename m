From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:41:57 +0000 (UTC)
Subject: master - cleanup: drop unused header files
Message-ID: <20160704154157.DC25A60E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0a505b0bb4eb6584bfea54b526ce38bdfcfa838
Commit:        c0a505b0bb4eb6584bfea54b526ce38bdfcfa838
Parent:        adc1fe4b3f84b341383d9737162397426e1a1295
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 15:37:31 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:40:24 2016 +0200

cleanup: drop unused header files

---
 lib/format_text/archiver.c |    1 -
 lib/metadata/lv_manip.c    |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 2acd8f5..92799e4 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -22,7 +22,6 @@
 #include "memlock.h"
 #include "toolcontext.h"
 #include "locking.h"
-#include "lvmetad-client.h"
 
 #include <unistd.h>
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6f02b16..5cf9618 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -28,7 +28,6 @@
 #include "str_list.h"
 #include "defaults.h"
 #include "lvm-exec.h"
-#include "lvm-signal.h"
 #include "memlock.h"
 #include "lvmlockd.h"
 


