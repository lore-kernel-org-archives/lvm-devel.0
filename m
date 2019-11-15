From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Nov 2019 06:38:31 -0500
Subject: master - revert "dmeventd: vdo plugin link lvm library"
Message-ID: <30713.119111506382600133@us-mta-40.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dccc50f6f60390b18e5387cd38647209f36fa998
Commit:        dccc50f6f60390b18e5387cd38647209f36fa998
Parent:        7ea71a9eb94a703975d8f59f941d02039def3be4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 12:20:28 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:37:41 2019 +0100

revert "dmeventd: vdo plugin link lvm library"

This reverts commit cbabdf2fca6131660cfb5525ed9edb3f7a41525a.
and add extra comment why this code may look unused, but
in runtime is necessary.
---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index 7c4ec47..399b737 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -16,6 +16,14 @@
 #include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 
+/*
+ * Use parser from new device_mapper library.
+ * Although during compilation we can see dm_vdo_status_parse()
+ * in runtime we are linked agains systems libdm 'older' library
+ * which does not provide this symbol and plugin fails to load
+ */
+#include "device_mapper/vdo/status.c"
+
 #include <sys/wait.h>
 #include <stdarg.h>
 



