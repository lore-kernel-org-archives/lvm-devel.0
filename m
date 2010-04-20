From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Apr 2010 15:19:37 -0000
Subject: LVM2/test t-000-basic.sh
Message-ID: <20100420151937.14111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-20 15:19:36

Modified files:
	test           : t-000-basic.sh 

Log message:
	Add device creation to basic nightly test.
	
	Ensure we can create devices for use in tests before running the real
	tests.  This may in various cases, and may involve machine configuration
	rather than a failure in some specific test.
	For example, if a test is run with LVM_TEST_DIR=/tmp, selinux is enabled,
	and the default security context is set to "<<none>>" for /tmp, all the
	tests will fail, unable to create devices, since dmsetup will fail, a
	result of machpathcon() returning an error code.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-000-basic.sh	2010/04/07 14:46:26	1.8
+++ LVM2/test/t-000-basic.sh	2010/04/20 15:19:36	1.9
@@ -24,3 +24,7 @@
   error "Can't create nodes on filesystem"
 echo >$DM_DEV_DIR/null || 
   error "Filesystem for tests does not allow using device nodes (check nodev)"
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 5
+


