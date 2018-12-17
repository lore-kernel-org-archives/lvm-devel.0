From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:01 -0500
Subject: master - dmeventd: fix linking with libdevmapper
Message-ID: <201812171008.wBHA81Ed024731@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=035a7b9a4bf77798d9d7ecdb7cfa8dfd77a92729
Commit:        035a7b9a4bf77798d9d7ecdb7cfa8dfd77a92729
Parent:        c666e8d25e724802a85489c548adc763949fdfa9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:28:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 22:33:22 2018 +0100

dmeventd: fix linking with libdevmapper

Since dmeventd is 'libdm' based project, it needs to link
libdm library instead of its internal version

An external users may provide plugins loadeable by dmeventd.
So external user of libdevmapper-event library has no other option
then to link with released libdevmapper library.

The complexity comes with lvm2 plugins.
The lvm2 plugin itself uses internal version of device_mapper,
but libdevmapper-event usage is libdm based - so there needs to be avoided
any breakage on compatibility of internal i.e. dm_task_run structures.

TODO: most likely dmeventd itself should be moved into libdm/dm-tools dir,
and only lvm2 plugins should be created as part of lvm project,
but those still need to link with libdevmapper.
---
 daemons/dmeventd/Makefile.in          |    3 +--
 daemons/dmeventd/dmeventd.c           |   13 ++++++-------
 daemons/dmeventd/libdevmapper-event.c |    9 +++++----
 daemons/dmeventd/libdevmapper-event.h |    1 +
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 0a03d66..6bd36d0 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -57,8 +57,7 @@ all: device-mapper
 device-mapper: $(TARGETS)
 
 CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
-LIBS += $(PTHREAD_LIBS)
-LIBS += $(INTERNAL_LIBS)
+LIBS += $(PTHREAD_LIBS) -L$(top_builddir)/libdm -ldevmapper
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	@echo "    [CC] $@"
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index dcc743d..4a58449 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,14 +16,13 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
-#include "device_mapper/misc/dmlib.h"
-#include "base/memory/zalloc.h"
-#include "device_mapper/misc/dm-logging.h"
 
-#include "daemons/dmeventd/libdevmapper-event.h"
+#include "configure.h"
+#include "libdevmapper-event.h"
 #include "dmeventd.h"
 
-#include "tools/tool.h"
+#include "libdm/misc/dm-logging.h"
+#include "base/memory/zalloc.h"
 
 #include <dlfcn.h>
 #include <pthread.h>
@@ -35,6 +34,8 @@
 #include <signal.h>
 #include <arpa/inet.h>		/* for htonl, ntohl */
 #include <fcntl.h>		/* for musl libc */
+#include <unistd.h>
+#include <syslog.h>
 
 #ifdef __linux__
 /*
@@ -62,8 +63,6 @@
 
 #endif
 
-#include <syslog.h>
-
 #define DM_SIGNALED_EXIT  1
 #define DM_SCHEDULED_EXIT 2
 static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given to exit */
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 1c4607a..6465f64 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -12,11 +12,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "device_mapper/misc/dmlib.h"
-#include "base/memory/zalloc.h"
-#include "device_mapper/misc/dm-logging.h"
-#include "daemons/dmeventd/libdevmapper-event.h"
+#include "configure.h"
+#include "libdevmapper-event.h"
 #include "dmeventd.h"
+#include "libdm/misc/dm-logging.h"
+#include "base/memory/zalloc.h"
+
 #include "lib/misc/intl.h"
 
 #include <fcntl.h>
diff --git a/daemons/dmeventd/libdevmapper-event.h b/daemons/dmeventd/libdevmapper-event.h
index 4c97223..cc65e72 100644
--- a/daemons/dmeventd/libdevmapper-event.h
+++ b/daemons/dmeventd/libdevmapper-event.h
@@ -21,6 +21,7 @@
 #ifndef LIB_DMEVENT_H
 #define LIB_DMEVENT_H
 
+#include <stdarg.h>
 #include <stdint.h>
 
 /*


