From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Nov 2010 16:13:19 -0000
Subject: LVM2 ./make.tmpl.in scripts/Makefile.in
Message-ID: <20101105161319.18965.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-05 16:13:19

Modified files:
	.              : make.tmpl.in 
	scripts        : Makefile.in 

Log message:
	Add given user prefix to make target install_initscripts
	
	Avoid files to be written into the live system if lvm was
	configured with different --prefix.
	
	Use initdir for install target path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/make.tmpl.in	2010/10/07 16:33:35	1.112
+++ LVM2/make.tmpl.in	2010/11/05 16:13:18	1.113
@@ -64,6 +64,8 @@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
+initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
+
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
--- LVM2/scripts/Makefile.in	2010/05/20 14:45:17	1.18
+++ LVM2/scripts/Makefile.in	2010/11/05 16:13:19	1.19
@@ -33,13 +33,13 @@
 
 # FIXME Customise for other distributions
 install_initscripts:
-	$(INSTALL_DIR) $(DESTDIR)/etc/rc.d/init.d
-	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(DESTDIR)/etc/rc.d/init.d/lvm2-monitor
+	$(INSTALL_DIR) $(initdir)
+	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
 ifneq ("@CLVMD@", "none")
-	$(INSTALL_SCRIPT) clvmd_init_red_hat $(DESTDIR)/etc/rc.d/init.d/clvmd
+	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initdir)/clvmd
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
-	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(DESTDIR)/etc/rc.d/init.d/cmirrord
+	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
 
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat


