From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:03 -0400
Subject: master - cmirrord: deamon links libdm
Message-ID: <201910041533.x94FX3HL030963@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebc9274be07299e1defd332685a2dff2c5b43cdf
Commit:        ebc9274be07299e1defd332685a2dff2c5b43cdf
Parent:        a68258339da7e56910a2a3f6f98e43424ac219b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 17:23:34 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

cmirrord: deamon links libdm

Correct included header files for this outdated tool since
it's linked with libdm, it need to use header files from this dir.
---
 daemons/cmirrord/cluster.h   |    2 +-
 daemons/cmirrord/functions.h |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/cluster.h b/daemons/cmirrord/cluster.h
index 0efbd64..ccb2f35 100644
--- a/daemons/cmirrord/cluster.h
+++ b/daemons/cmirrord/cluster.h
@@ -12,8 +12,8 @@
 #ifndef _LVM_CLOG_CLUSTER_H
 #define _LVM_CLOG_CLUSTER_H
 
-#include "libdm/misc/dm-log-userspace.h"
 #include "libdm/libdevmapper.h"
+#include "libdm/misc/dm-log-userspace.h"
 
 #define DM_ULOG_RESPONSE 0x1000U /* in last byte of 32-bit value */
 #define DM_ULOG_CHECKPOINT_READY 21
diff --git a/daemons/cmirrord/functions.h b/daemons/cmirrord/functions.h
index 8a7301d..524fd0b 100644
--- a/daemons/cmirrord/functions.h
+++ b/daemons/cmirrord/functions.h
@@ -12,7 +12,8 @@
 #ifndef _LVM_CLOG_FUNCTIONS_H
 #define _LVM_CLOG_FUNCTIONS_H
 
-#include "device_mapper/misc/dm-log-userspace.h"
+#include "libdm/libdevmapper.h"
+#include "libdm/misc/dm-log-userspace.h"
 #include "cluster.h"
 
 #define LOG_RESUMED   1


