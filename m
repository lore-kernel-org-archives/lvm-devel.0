From: Gabriele Gristina <gabriele.gristina@gmail.com>
Date: Sat, 1 Oct 2011 22:02:35 +0200
Subject: patch for build lvm2 with --enable_static-link
Message-ID: <CAAQoy1S2KXVHUMv-0+=T6FR_o4vQOZP41hSnzArBVYGMk8a5Aw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

here the working patch for build lvm2 with --enable_static-link



diff -Naur LVM2/configure.in LVM2.new/configure.in
--- LVM2/configure.in    2011-09-24 20:57:49.000000000 +0000
+++ LVM2.new/configure.in    2011-10-01 19:38:20.667538017 +0000
@@ -35,6 +35,7 @@
         CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
         LDDEPS="$LDDEPS .export.sym"
         LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
+        LDFLAGS_STATIC="$LDFLAGS -Wl"
         LIB_SUFFIX=so
         DEVMAPPER=yes
         LVMETAD=no
diff -Naur LVM2/make.tmpl.in LVM2.new/make.tmpl.in
--- LVM2/make.tmpl.in    2011-08-12 12:56:38.000000000 +0000
+++ LVM2.new/make.tmpl.in    2011-10-01 19:48:55.337537503 +0000
@@ -134,6 +134,7 @@
 endif

 LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
+LDFLAGS_STATIC += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib

 ifeq ("@DMEVENTD@", "yes")
diff -Naur LVM2/tools/Makefile.in LVM2.new/tools/Makefile.in
--- LVM2/tools/Makefile.in    2011-09-24 21:00:53.000000000 +0000
+++ LVM2.new/tools/Makefile.in    2011-10-01 19:39:19.987537981 +0000
@@ -126,7 +126,7 @@
           -o $@ dmsetup.o -ldevmapper $(LIBS)

 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
-    $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
+    $(CC) $(CFLAGS) $(LDFLAGS_STATIC) -static -L$(interfacebuilddir) \
           -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)

 all: device-mapper
@@ -136,7 +136,7 @@
         $(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic

 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a
$(interfacebuilddir)/libdevmapper.a
-    $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
+    $(CC) $(CFLAGS) $(LDFLAGS_STATIC) -static -L$(interfacebuilddir) -o $@
\
           $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)

 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o
lvm2cmd.o
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111001/1f756cb3/attachment.htm>
