From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:19 -0500
Subject: master - headers: use full path header instead of -I directive
Message-ID: <201812141417.wBEEHJcT010287@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63b0f0dab8b9a86b5cae6592f8cbea2eac0b70a3
Commit:        63b0f0dab8b9a86b5cae6592f8cbea2eac0b70a3
Parent:        0b19387dae782b33bb341e58ab3c7ff804ca4f14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 3 18:15:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:13:38 2018 +0100

headers: use full path header instead of -I directive

Replace Makefile -I  with full path to headers like we use now
everywhere else.
---
 daemons/dmeventd/plugins/mirror/Makefile.in        |    1 -
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    2 +-
 daemons/dmeventd/plugins/raid/Makefile.in          |    1 -
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    4 ++--
 daemons/dmeventd/plugins/snapshot/Makefile.in      |    1 -
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    2 +-
 daemons/dmeventd/plugins/thin/Makefile.in          |    1 -
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    2 +-
 daemons/dmeventd/plugins/vdo/Makefile.in           |    1 -
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c        |    2 +-
 10 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index a28b9e5..2c0d5d7 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -16,7 +16,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_mirror.c
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index ca483fd..5f1db32 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -13,8 +13,8 @@
  */
 
 #include "lib/misc/lib.h"
+#include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
-#include "dmeventd_lvm.h"
 #include "lib/activate/activate.h"
 
 /* FIXME Reformat to 80 char lines. */
diff --git a/daemons/dmeventd/plugins/raid/Makefile.in b/daemons/dmeventd/plugins/raid/Makefile.in
index d38ca15..c00e624 100644
--- a/daemons/dmeventd/plugins/raid/Makefile.in
+++ b/daemons/dmeventd/plugins/raid/Makefile.in
@@ -15,7 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_raid.c
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 7871500..aa2b578 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -13,9 +13,9 @@
  */
 
 #include "lib/misc/lib.h"
-#include "lib/config/defaults.h"
-#include "dmeventd_lvm.h"
+#include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
+#include "lib/config/defaults.h"
 
 /* Hold enough elements for the mximum number of RAID images */
 #define	RAID_DEVS_ELEMS	((DEFAULT_RAID_MAX_IMAGES + 63) / 64)
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index ab46b43..adbb3e2 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -16,7 +16,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_snapshot.c
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 9e9053c..9c49a72 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib/misc/lib.h"
-#include "dmeventd_lvm.h"
+#include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 
 #include <sys/sysmacros.h>
diff --git a/daemons/dmeventd/plugins/thin/Makefile.in b/daemons/dmeventd/plugins/thin/Makefile.in
index b1e3e1b..7968504 100644
--- a/daemons/dmeventd/plugins/thin/Makefile.in
+++ b/daemons/dmeventd/plugins/thin/Makefile.in
@@ -15,7 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_thin.c
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 64fe6ca..5ff5bb8 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib/misc/lib.h"
-#include "dmeventd_lvm.h"
+#include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 
 #include <sys/wait.h>
diff --git a/daemons/dmeventd/plugins/vdo/Makefile.in b/daemons/dmeventd/plugins/vdo/Makefile.in
index bda738a..8e90e27 100644
--- a/daemons/dmeventd/plugins/vdo/Makefile.in
+++ b/daemons/dmeventd/plugins/vdo/Makefile.in
@@ -15,7 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_vdo.c
diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index abed41e..b5e2766 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -13,7 +13,7 @@
  */
 
 #include "lib/misc/lib.h"
-#include "dmeventd_lvm.h"
+#include "daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
 #include "device_mapper/vdo/target.h"
 


