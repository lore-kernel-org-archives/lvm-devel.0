From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 15 Aug 2013 08:01:03 +0000 (UTC)
Subject: master - systemd: use LVM_PATH instead of hardcoded value in activation generator
Message-ID: <20130815080103.D702960539@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cbbe851a80e8d99dc886ce9b44834137731d8ce
Commit:        8cbbe851a80e8d99dc886ce9b44834137731d8ce
Parent:        c29c64f20dadbd9076d8729bd3d0cb724c4b39b0
Author:        Michael Stapelberg <stapelberg@debian.org>
AuthorDate:    Thu Aug 15 09:57:30 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 15 09:59:19 2013 +0200

systemd: use LVM_PATH instead of hardcoded value in activation generator

---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 903b28d..a4df6c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Use LVM_PATH instead of hardcoded value in lvm2 activation systemd generator.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Fix vgck to notice on-disk corruption even if lvmetad is used.
   Move mpath device filter before partitioned filter (which opens devices).
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 17bc71a..9d4b581 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -22,6 +22,7 @@
 #include <fcntl.h>
 #include <limits.h>		/* For PATH_MAX for musl libc */
 #include "lvm2app.h"
+#include "configure.h"		/* for LVM_PATH */
 
 #define KMSG_DEV_PATH        "/dev/kmsg"
 #define LVM_CONF_USE_LVMETAD "global/use_lvmetad"
@@ -150,7 +151,7 @@ static int generate_unit(const char *dir, int unit)
 		      "[Service]\n", f);
 	}
 
-	fputs("ExecStart=/usr/sbin/lvm vgchange -aay --sysinit\n"
+	fputs("ExecStart=" LVM_PATH " vgchange -aay --sysinit\n"
 	      "Type=oneshot\n", f);
 
 	if (fclose(f) < 0) {


