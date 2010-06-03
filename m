From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Jun 2010 13:52:22 -0000
Subject: LVM2 ./make.tmpl.in tools/Makefile.in
Message-ID: <20100603135222.2542.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-03 13:52:22

Modified files:
	.              : make.tmpl.in 
	tools          : Makefile.in 

Log message:
	Use INSTALL_DIR to create directories

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/make.tmpl.in	2010/05/20 22:54:58	1.102
+++ LVM2/make.tmpl.in	2010/06/03 13:52:21	1.103
@@ -312,7 +312,7 @@
 
 install_lib_shared: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
-	$(INSTALL) -d $(usrlibdir)
+	$(INSTALL_DIR) $(usrlibdir)
 	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 # FIXME: plugins are installed to subdirs 
--- LVM2/tools/Makefile.in	2010/05/11 08:34:38	1.118
+++ LVM2/tools/Makefile.in	2010/06/03 13:52:21	1.119
@@ -171,7 +171,7 @@
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
-	$(INSTALL) -d $(usrlibdir)
+	$(INSTALL_DIR) $(usrlibdir)
 	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 install_cmdlib_static: liblvm2cmd-static.a


