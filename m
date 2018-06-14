From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:43 -0400
Subject: master - build: drop some lvm references from libdm making
Message-ID: <201806142002.w5EK2hd4003515@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a457566e918840e2f21e724afd1b7f470fcbb02a
Commit:        a457566e918840e2f21e724afd1b7f470fcbb02a
Parent:        c6be40960917de0e3baab23ab44c64c682895049
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 20:38:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

build: drop some lvm references from libdm making

Some simplification, more may follow...
---
 libdm/make.tmpl.in |   55 +++------------------------------------------------
 1 files changed, 4 insertions(+), 51 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index fc29034..1365fd1 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -53,9 +53,6 @@ WC = @WC@
 AR = @AR@
 RM = rm -f
 
-PYTHON2 = @PYTHON2@
-PYTHON3 = @PYTHON3@
-PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
 LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) -lm
@@ -69,9 +66,6 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS=\
-	-llvm-internal \
-	$(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
@@ -250,20 +244,6 @@ ifeq (,$(findstring -g,$(CFLAGS)))
 endif
   CFLAGS += -fno-omit-frame-pointer
   DEFS += -DDEBUG
-  # memory debugging is not thread-safe yet
-  ifneq ("@BUILD_DMEVENTD@", "yes")
-  ifneq ("@BUILD_DMFILEMAPD@", "yes")
-  ifneq ("@BUILD_LVMLOCKD@", "yes")
-  ifneq ("@BUILD_LVMPOLLD@", "yes")
-  ifneq ("@BUILD_LVMETAD@", "yes")
-  ifeq ("@CLVMD@", "none")
-    DEFS += -DDEBUG_MEM
-  endif
-  endif
-  endif
-  endif
-  endif
-  endif
 endif
 
 # end of fPIC protection
@@ -271,18 +251,8 @@ endif
 
 DEFS += -D_BUILDING_LVM
 
-LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
-CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
-
-DAEMON_LIBS = -ldaemonclient
-LDFLAGS += -L$(top_builddir)/libdaemon/client
-CLDFLAGS += -L$(top_builddir)/libdaemon/client
-
-ifeq ("@BUILD_DMEVENTD@", "yes")
-  DMEVENT_LIBS = -ldevmapper-event
-  LDFLAGS += -L$(top_builddir)/daemons/dmeventd
-  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
-endif
+LDFLAGS += -L$(top_builddir)/libdm
+CLDFLAGS += -L$(top_builddir)/libdm
 
 # Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
 #DEFS += -DDEBUG_POOL
@@ -307,8 +277,6 @@ LIB_VERSION_LVM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir
 
 LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION_DM)
 
-LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
-
 INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
 
@@ -319,22 +287,19 @@ OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
-.PHONY: install install_cluster install_device-mapper install_lvm2
+.PHONY: install install_device-mapper install_lvm2
 .PHONY: install_dbus_service
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
 .PHONY: install_ocf install_systemd_generators install_all_man all_man man help
 .PHONY: python_bindings install_python_bindings
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
-.PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
+.PHONY: $(SUBDIRS.pofile) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
 .PHONY: $(SUBDIRS.generate) generate
 
 SUBDIRS.device-mapper := $(SUBDIRS:=.device-mapper)
 SUBDIRS.install := $(SUBDIRS:=.install)
-SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
 SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
-SUBDIRS.install_lvm2 := $(SUBDIRS:=.install_lvm2)
-SUBDIRS.install_ocf := $(SUBDIRS:=.install_ocf)
 SUBDIRS.pofile := $(SUBDIRS:=.pofile)
 SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
@@ -345,10 +310,7 @@ TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 all: $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
-install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
-install_lvm2: $(SUBDIRS.install_lvm2)
-install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
@@ -360,18 +322,9 @@ $(SUBDIRS.device-mapper):
 $(SUBDIRS.install): $(SUBDIRS)
 	$(MAKE) -C $(@:.install=) install
 
-$(SUBDIRS.install_cluster): $(SUBDIRS)
-	$(MAKE) -C $(@:.install_cluster=) install_cluster
-
 $(SUBDIRS.install_device-mapper): device-mapper
 	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
 
-$(SUBDIRS.install_lvm2): $(SUBDIRS)
-	$(MAKE) -C $(@:.install_lvm2=) install_lvm2
-
-$(SUBDIRS.install_ocf):
-	$(MAKE) -C $(@:.install_ocf=) install_ocf
-
 $(SUBDIRS.clean):
 	-$(MAKE) -C $(@:.clean=) clean
 


