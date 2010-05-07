From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:48 +0200
Subject: [PATCH 1/9] Not using pthread library functions here
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <520603bf9c7a30660bb4f1aa66619c559eb867ea.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    2 --
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    3 +--
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 4d2eee5..788f9f5 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -19,8 +19,6 @@
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
-#include <pthread.h>
-
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 /* FIXME Replace most syslogs with log_error() style messages and add complete context. */
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 01bb2c2..3c85c6d 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,7 +21,6 @@
 
 #include "lvm-string.h"
 
-#include <pthread.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
-- 
1.7.0.1


