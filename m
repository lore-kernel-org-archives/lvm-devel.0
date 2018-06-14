From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:43 -0400
Subject: master - build: drop libdm referring from lvm code
Message-ID: <201806142002.w5EK2hfN003520@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52ab3c1584cd40572e82d6add7a7c71204fa9721
Commit:        52ab3c1584cd40572e82d6add7a7c71204fa9721
Parent:        a457566e918840e2f21e724afd1b7f470fcbb02a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 20:48:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

build: drop libdm referring from lvm code

Avoid adding /libdm  paths into lvm building.
---
 make.tmpl.in |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 0790d7b..07cb18a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -144,7 +144,6 @@ vpath %.po $(srcdir)
 vpath %.exported_symbols $(srcdir)
 
 interface = @interface@
-interfacebuilddir = $(top_builddir)/libdm/$(interface)
 rpmbuilddir = $(abs_top_builddir)/build
 
 # The number of jobs to run, if blank, defaults to the make standard
@@ -252,18 +251,14 @@ endif
   DEFS += -DDEBUG
   # memory debugging is not thread-safe yet
   ifneq ("@BUILD_DMEVENTD@", "yes")
-  ifneq ("@BUILD_DMFILEMAPD@", "yes")
   ifneq ("@BUILD_LVMLOCKD@", "yes")
   ifneq ("@BUILD_LVMPOLLD@", "yes")
   ifneq ("@BUILD_LVMETAD@", "yes")
-  ifeq ("@CLVMD@", "none")
     DEFS += -DDEBUG_MEM
   endif
   endif
   endif
   endif
-  endif
-  endif
 endif
 
 # end of fPIC protection
@@ -271,8 +266,8 @@ endif
 
 DEFS += -D_BUILDING_LVM
 
-LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
-CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
+LDFLAGS += -L$(top_builddir)/lib
+CLDFLAGS += -L$(top_builddir)/lib
 
 DAEMON_LIBS = -ldaemonclient
 LDFLAGS += -L$(top_builddir)/libdaemon/client
@@ -426,8 +421,6 @@ CFLOW_FLAGS +=\
  --symbol __REDIRECT:wrapper \
  --symbol __REDIRECT_NTH:wrapper \
  --symbol __wur:wrapper \
- -I$(top_srcdir)/libdm \
- -I$(top_srcdir)/libdm/ioctl \
  -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2/ \
  $(INCLUDES) $(DEFS)
 


