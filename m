From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 May 2010 18:54:53 -0000
Subject: LVM2/test Makefile.in test-utils.sh
Message-ID: <20100506185453.2064.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-06 18:54:52

Modified files:
	test           : Makefile.in test-utils.sh 

Log message:
	Add some basic provisions for automated testing of dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/test/Makefile.in	2010/04/30 14:33:39	1.39
+++ LVM2/test/Makefile.in	2010/05/06 18:54:51	1.40
@@ -78,7 +78,11 @@
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
 	LDLPATH="\$$abs_top_builddir/libdm"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/tools"; \
 	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/lvm2"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/mirror"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/snapshot"; \
 	echo "export LD_LIBRARY_PATH=\"$$LDLPATH\"" >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
@@ -99,6 +103,7 @@
 	done
 	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
 	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
+	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" bin/dmeventd
 	touch $@
 
 lvm-wrapper: Makefile
--- LVM2/test/test-utils.sh	2010/04/20 18:18:59	1.38
+++ LVM2/test/test-utils.sh	2010/05/06 18:54:52	1.39
@@ -72,6 +72,22 @@
 	LOCAL_CLVMD="$!"
 }
 
+prepare_dmeventd() {
+	if pgrep dmeventd ; then
+		echo "Cannot test dmeventd with real dmeventd ($(pgrep clvmd)) running."
+		exit 200
+	fi
+
+	# skip if we don't have our own dmeventd...
+	(which dmeventd | grep $abs_builddir) || exit 200
+
+	trap_teardown
+
+	dmeventd -d &
+	LOCAL_DMEVENTD="$!"
+	strace -p $LOCAL_DMEVENTD &
+}
+
 prepare_testroot() {
 	OLDPWD="`pwd`"
 	PREFIX="LVMTEST$$"
@@ -127,6 +143,8 @@
 		kill -9 "$LOCAL_CLVMD" || true
 	}
 
+	test -n "$LOCAL_DMEVENTD" && kill -9 "$LOCAL_DMEVENTD"
+
 	teardown_devs
 
 	test -n "$TESTDIR" && {


