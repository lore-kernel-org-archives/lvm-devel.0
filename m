From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Apr 2010 21:34:40 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./make.tmpl.in ...
Message-ID: <20100409213440.10960.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-09 21:34:32

Modified files:
	.              : Makefile.in WHATS_NEW make.tmpl.in 
	daemons        : Makefile.in 
	daemons/clvmd  : Makefile.in 
	daemons/cmirrord: Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins: Makefile.in 
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	doc            : Makefile.in 
	lib            : Makefile.in 
	lib/format1    : Makefile.in 
	lib/format_pool: Makefile.in 
	lib/locking    : Makefile.in 
	lib/mirror     : Makefile.in 
	lib/snapshot   : Makefile.in 
	libdm          : Makefile.in 
	liblvm         : Makefile.in 
	man            : Makefile.in 
	po             : Makefile.in 
	scripts        : Makefile.in 
	test/api       : Makefile.in 
	tools          : Makefile.in 
	udev           : Makefile.in 

Log message:
	Use vpath instead of VPATH.
	
	Usage of VPATH makes troubles when used within $(builddir).
	Not only source files are being found through VPATH,
	but targets as well. (make --debug=v)
	
	Thus if user builds the code in $(srcdir) and also in some $(builddir)
	he gets mangled results as some generated files (i.e. .export.sym)
	are 'reused' from $(srcdir) instead of $(builddir).
	
	This patch switches to use vpath were we could explicitly name
	suffixes that should be looked via vpath - we must take care,
	we do not generate files with these suffixes:
	.c, .in, .po, .exported_symbols

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1507&r2=1.1508
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/Makefile.in	2010/04/06 11:53:53	1.50
+++ LVM2/Makefile.in	2010/04/09 21:34:25	1.51
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SUBDIRS = doc include man scripts
 
--- LVM2/WHATS_NEW	2010/04/09 01:00:10	1.1507
+++ LVM2/WHATS_NEW	2010/04/09 21:34:25	1.1508
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Switch from using VPATH  to vpath in Makefiles.
   Permit mimage LVs to be striped in lvcreate and lvresize.
   Fix pvmove allocation to take existing parallel stripes into account.
   Add pvmove_source_seg to struct lv_segment.
--- LVM2/make.tmpl.in	2010/04/08 09:15:37	1.88
+++ LVM2/make.tmpl.in	2010/04/09 21:34:25	1.89
@@ -63,6 +63,12 @@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 
+# Setup vpath search paths for some suffixes
+vpath %.c $(srcdir)
+vpath %.in $(srcdir)
+vpath %.po $(srcdir)
+vpath %.exported_symbols $(srcdir)
+
 interface = @interface@
 interfacebuilddir = $(top_builddir)/libdm/$(interface)
 
--- LVM2/daemons/Makefile.in	2010/03/29 14:11:17	1.15
+++ LVM2/daemons/Makefile.in	2010/04/09 21:34:25	1.16
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 .PHONY: dmeventd clvmd cmirrord
 
--- LVM2/daemons/clvmd/Makefile.in	2010/03/29 14:18:00	1.38
+++ LVM2/daemons/clvmd/Makefile.in	2010/04/09 21:34:26	1.39
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CCS_LIBS = @CCS_LIBS@
 CCS_CFLAGS = @CCS_CFLAGS@
--- LVM2/daemons/cmirrord/Makefile.in	2010/03/04 09:51:38	1.7
+++ LVM2/daemons/cmirrord/Makefile.in	2010/04/09 21:34:26	1.8
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:18:00	1.39
+++ LVM2/daemons/dmeventd/Makefile.in	2010/04/09 21:34:26	1.40
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = libdevmapper-event.c
 SOURCES2 = dmeventd.c
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2010/03/04 09:51:38	1.7
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2010/04/09 21:34:27	1.8
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SUBDIRS += lvm2 mirror snapshot
 
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/03/04 11:21:05	1.3
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2010/04/09 21:34:27	1.4
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 CLDFLAGS += -L$(top_builddir)/tools
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/29 14:11:18	1.17
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/04/09 21:34:27	1.18
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/03/04 11:21:06	1.12
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/04/09 21:34:27	1.13
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
 CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
--- LVM2/doc/Makefile.in	2010/03/04 09:51:38	1.7
+++ LVM2/doc/Makefile.in	2010/04/09 21:34:28	1.8
@@ -14,9 +14,8 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
-CONFSRC=example.conf
+CONFSRC=$(srcdir)/example.conf
 CONFDEST=lvm.conf
 
 include $(top_builddir)/make.tmpl
--- LVM2/lib/Makefile.in	2010/03/29 14:18:00	1.100
+++ LVM2/lib/Makefile.in	2010/04/09 21:34:28	1.101
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@LVM1@", "shared")
   SUBDIRS = format1
--- LVM2/lib/format1/Makefile.in	2010/03/04 09:51:39	1.12
+++ LVM2/lib/format1/Makefile.in	2010/04/09 21:34:29	1.13
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	disk-rep.c \
--- LVM2/lib/format_pool/Makefile.in	2010/03/04 09:51:39	1.8
+++ LVM2/lib/format_pool/Makefile.in	2010/04/09 21:34:29	1.9
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	disk_rep.c \
--- LVM2/lib/locking/Makefile.in	2010/03/04 09:51:39	1.6
+++ LVM2/lib/locking/Makefile.in	2010/04/09 21:34:29	1.7
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = cluster_locking.c
 
--- LVM2/lib/mirror/Makefile.in	2010/03/04 09:51:39	1.7
+++ LVM2/lib/mirror/Makefile.in	2010/04/09 21:34:29	1.8
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = mirrored.c
 
--- LVM2/lib/snapshot/Makefile.in	2010/03/04 09:51:40	1.7
+++ LVM2/lib/snapshot/Makefile.in	2010/04/09 21:34:30	1.8
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES = snapshot.c
 
--- LVM2/libdm/Makefile.in	2010/03/29 14:18:01	1.52
+++ LVM2/libdm/Makefile.in	2010/04/09 21:34:30	1.53
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	datastruct/bitset.c \
--- LVM2/liblvm/Makefile.in	2010/03/04 11:12:40	1.20
+++ LVM2/liblvm/Makefile.in	2010/04/09 21:34:30	1.21
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	lvm_misc.c \
--- LVM2/man/Makefile.in	2010/03/29 14:22:00	1.34
+++ LVM2/man/Makefile.in	2010/04/09 21:34:30	1.35
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@FSADM@", "yes")
 FSADMMAN = fsadm.8
--- LVM2/po/Makefile.in	2010/03/04 09:51:41	1.8
+++ LVM2/po/Makefile.in	2010/04/09 21:34:31	1.9
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 LANGS=de
 
--- LVM2/scripts/Makefile.in	2010/03/04 09:51:41	1.13
+++ LVM2/scripts/Makefile.in	2010/04/09 21:34:31	1.14
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 include $(top_builddir)/make.tmpl
 
--- LVM2/test/api/Makefile.in	2010/03/04 11:21:06	1.12
+++ LVM2/test/api/Makefile.in	2010/04/09 21:34:31	1.13
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
--- LVM2/tools/Makefile.in	2010/03/31 07:37:16	1.114
+++ LVM2/tools/Makefile.in	2010/04/09 21:34:32	1.115
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES =\
 	dumpconfig.c \
@@ -146,7 +145,7 @@
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 
-.commands: commands.h cmdnames.h Makefile
+.commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
 
--- LVM2/udev/Makefile.in	2010/03/31 07:40:20	1.6
+++ LVM2/udev/Makefile.in	2010/04/09 21:34:32	1.7
@@ -14,7 +14,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules
@@ -24,6 +23,8 @@
 
 include $(top_builddir)/make.tmpl
 
+vpath %.rules $(srcdir)
+
 %: %.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
 


