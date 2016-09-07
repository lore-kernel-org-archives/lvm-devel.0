From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  7 Sep 2016 14:44:15 +0000 (UTC)
Subject: master - cleanup: clean gcc6 minor/major types warnings
Message-ID: <20160907144415.4B59B60734@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6064a5084e2a71db389b1bdf06c05765610295d9
Commit:        6064a5084e2a71db389b1bdf06c05765610295d9
Parent:        5838c41a356eec05218395e734b90d21487f271c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 7 15:13:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 16:42:34 2016 +0200

cleanup: clean gcc6 minor/major types warnings

Put sys/sysmacros.h in front of sys/types.h header file as requested
by gcc6 part II.
---
 daemons/cmirrord/functions.c                       |    1 +
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 757d8e8..5e50b8a 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -12,6 +12,7 @@
 #include "logging.h"
 #include "functions.h"
 
+#include <sys/sysmacros.h>
 #include <dirent.h>
 #include <errno.h>
 #include <fcntl.h>
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 7b060ed..a70d07c 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -16,6 +16,7 @@
 #include "dmeventd_lvm.h"
 #include "libdevmapper-event.h"
 
+#include <sys/sysmacros.h>
 #include <sys/wait.h>
 #include <stdarg.h>
 #include <pthread.h>


