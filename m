From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 12 Feb 2017 16:30:46 +0000 (UTC)
Subject: master - coverity: remove unneeded header files
Message-ID: <20170212163046.DE16B60EEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0844b20f985177f60db48dc84bcde7170d17a77e
Commit:        0844b20f985177f60db48dc84bcde7170d17a77e
Parent:        375e38709ca2842c97ee56899a8a3f34abc61a30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 21:17:27 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 11 21:17:27 2017 +0100

coverity: remove unneeded header files

---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    1 -
 lib/metadata/raid_manip.c                     |    1 -
 lib/misc/lvm-flock.c                          |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index f551971..cf57d20 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -18,7 +18,6 @@
 
 #include <sys/wait.h>
 #include <stdarg.h>
-#include <pthread.h>
 
 /* TODO - move this mountinfo code into library to be reusable */
 #ifdef __linux__
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 25783a8..0f0631f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -21,7 +21,6 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
-#include "lvm-signal.h"
 
 static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 {
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 0b90f8f..22eb128 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "config.h"
-#include "lvm-file.h"
 #include "lvm-flock.h"
 #include "lvm-signal.h"
 #include "locking.h"


