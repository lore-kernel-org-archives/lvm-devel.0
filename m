From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:11 +0000 (UTC)
Subject: master - cleanup: move system defines before structs
Message-ID: <20151013140411.91040602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09a8479cb70ea2761ebd6988926017aa13fc5f5d
Commit:        09a8479cb70ea2761ebd6988926017aa13fc5f5d
Parent:        0a633750f1e43aa655e5e6e05269aeab8650f55d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 11:35:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:58 2015 +0200

cleanup: move system defines before structs

---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 0801adf..d21e65b 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -19,11 +19,19 @@
 #include <sys/wait.h>
 #include <stdarg.h>
 
-/* First warning when thin is 80% full. */
+/* TODO - move this mountinfo code into library to be reusable */
+#ifdef __linux__
+#  include "kdev_t.h"
+#else
+#  define MAJOR(x) major((x))
+#  define MINOR(x) minor((x))
+#endif
+
+/* First warning when thin data or metadata is 80% full. */
 #define WARNING_THRESH 80
 /* Run a check every 5%. */
 #define CHECK_STEP 5
-/* Do not bother checking thins less than 50% full. */
+/* Do not bother checking thin data or metadata is less than 50% full. */
 #define CHECK_MINIMUM 50
 
 #define UMOUNT_COMMAND "/bin/umount"
@@ -39,16 +47,6 @@ struct dso_state {
 	char cmd_str[1024];
 };
 
-
-/* TODO - move this mountinfo code into library to be reusable */
-#ifdef __linux__
-#  include "kdev_t.h"
-#else
-#  define MAJOR(x) major((x))
-#  define MINOR(x) minor((x))
-#  define MKDEV(x,y) makedev((x),(y))
-#endif
-
 DM_EVENT_LOG_FN("thin")
 
 /* Get dependencies for device, and try to find matching device */


