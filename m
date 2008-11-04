From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 16:41:50 -0000
Subject: LVM2/daemons Makefile.in clvmd/clvmd-cman.c cl ...
Message-ID: <20081104164150.17372.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 16:41:48

Modified files:
	daemons        : Makefile.in 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-gulm.c 
	                 clvmd-openais.c clvmd.c lvm-functions.c 
	                 refresh_clvmd.c tcp-comms.c 

Log message:
	clvmd

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/daemons/Makefile.in	2008/11/04 15:55:26	1.6
+++ LVM2/daemons/Makefile.in	2008/11/04 16:41:47	1.7
@@ -27,4 +27,6 @@
 
 include $(top_srcdir)/make.tmpl
 
+ifeq ("@DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
+endif
--- LVM2/daemons/clvmd/clvmd-cman.c	2008/05/09 07:20:04	1.23
+++ LVM2/daemons/clvmd/clvmd-cman.c	2008/11/04 16:41:47	1.24
@@ -17,6 +17,10 @@
  * CMAN communication layer for clvmd.
  */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/stat.h>
@@ -41,7 +45,7 @@
 
 #include "clvmd-comms.h"
 #include "clvm.h"
-#include "log.h"
+#include "lvm-logging.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 
--- LVM2/daemons/clvmd/clvmd-command.c	2008/11/04 15:07:44	1.25
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/11/04 16:41:47	1.26
@@ -50,6 +50,10 @@
 
 */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -68,7 +72,7 @@
 #include <libdlm.h>
 
 #include "locking.h"
-#include "log.h"
+#include "lvm-logging.h"
 #include "lvm-functions.h"
 #include "clvmd-comms.h"
 #include "clvm.h"
--- LVM2/daemons/clvmd/clvmd-gulm.c	2008/11/04 15:07:44	1.24
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2008/11/04 16:41:47	1.25
@@ -45,7 +45,7 @@
 #include <libgulm.h>
 
 #include "locking.h"
-#include "log.h"
+#include "lvm-logging.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/11/04 15:07:44	1.8
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/11/04 16:41:47	1.9
@@ -11,6 +11,10 @@
  *
  */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -40,7 +44,7 @@
 #include <openais/cpg.h>
 
 #include "locking.h"
-#include "log.h"
+#include "lvm-logging.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
--- LVM2/daemons/clvmd/clvmd.c	2008/11/04 15:07:44	1.50
+++ LVM2/daemons/clvmd/clvmd.c	2008/11/04 16:41:47	1.51
@@ -17,6 +17,12 @@
  * CLVMD: Cluster LVM daemon
  */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
+#include <libdevmapper.h>
+
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/stat.h>
@@ -46,7 +52,7 @@
 #include "version.h"
 #include "clvmd.h"
 #include "refresh_clvmd.h"
-#include "log.h"
+#include "lvm-logging.h"
 
 #ifndef TRUE
 #define TRUE 1
--- LVM2/daemons/clvmd/lvm-functions.c	2008/11/04 15:07:44	1.47
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/11/04 16:41:47	1.48
@@ -13,6 +13,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
@@ -42,7 +46,8 @@
 /* LVM2 headers */
 #include "toolcontext.h"
 #include "lvmcache.h"
-#include "log.h"
+#include "lvm-logging.h"
+#include "lvm-globals.h"
 #include "activate.h"
 #include "locking.h"
 #include "archiver.h"
--- LVM2/daemons/clvmd/refresh_clvmd.c	2008/03/06 08:41:05	1.5
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2008/11/04 16:41:47	1.6
@@ -18,6 +18,10 @@
  *
  */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
 #include <stddef.h>
 #include <sys/socket.h>
 #include <sys/un.h>
--- LVM2/daemons/clvmd/tcp-comms.c	2007/07/24 15:35:11	1.18
+++ LVM2/daemons/clvmd/tcp-comms.c	2008/11/04 16:41:47	1.19
@@ -13,7 +13,10 @@
    It can also make outgoing connnections to the other clvmd nodes.
 */
 
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
 
+#include <configure.h>
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>


