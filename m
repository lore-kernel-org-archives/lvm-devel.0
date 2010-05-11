From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:34:41 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in tools/Makefile.in
Message-ID: <20100511083441.1146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:34:39

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	tools          : Makefile.in 

Log message:
	Link liblvm2cmd.so with devmapper-event and devmapper libs.
	and remove generic %.so: %.a target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1550&r2=1.1551
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/WHATS_NEW	2010/05/07 15:24:17	1.1550
+++ LVM2/WHATS_NEW	2010/05/11 08:34:38	1.1551
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Link liblvm2cmd.so with devmapper-event and devmapper libs.
   Fix truncated total size displayed by pvscan.
   Add new --sysinit option for vgchange and lvchange.
   Suppress duplicate error messages about read failures and missing devices.
--- LVM2/make.tmpl.in	2010/05/06 10:07:46	1.94
+++ LVM2/make.tmpl.in	2010/05/11 08:34:38	1.95
@@ -320,11 +320,6 @@
 	$(LN_S) -f $(<F) $(libdir)/$(<F).$(LIB_VERSION)
 endif
 
-%.so: %.a
-	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(LIBS) -o $@ \
-	@CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@
-
 $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
 	$(AR) rs $@ $(OBJECTS)
--- LVM2/tools/Makefile.in	2010/04/15 15:12:20	1.117
+++ LVM2/tools/Makefile.in	2010/05/11 08:34:38	1.118
@@ -145,6 +145,9 @@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
+	$(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
+	$(CFLAGS) $(CLDFLAGS) -o $@ $(LVMLIBS) $(LIBS) \
+		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	$(LN_S) -f $< $@


