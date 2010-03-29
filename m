From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 15:53:12 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100329155312.15289.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 15:53:12

Modified files:
	test           : Makefile.in 

Log message:
	Fix also error code from clean:
	And fix previous commit which missed test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/test/Makefile.in	2010/03/29 15:39:25	1.31
+++ LVM2/test/Makefile.in	2010/03/29 15:53:11	1.32
@@ -70,7 +70,7 @@
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	if  "$(srcdir)" != . ; then  cp $(SCRIPTS) . ; fi
+	if test "$(srcdir)" != . ; then  cp $(SCRIPTS) . ; fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
@@ -97,7 +97,7 @@
 
 clean:
 	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
-	test "$(srcdir)" != . && rm -f $(subst $(srcdir)/, ,$(SCRIPTS)) lvm2app.sh
+	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(SCRIPTS)) lvm2app.sh ; fi
 
 distclean: clean
 	rm -f Makefile


