From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Mar 2010 22:18:17 -0000
Subject: LVM2/test harness.c test-utils.sh
Message-ID: <20100331221817.9757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-31 22:18:17

Modified files:
	test           : harness.c test-utils.sh 

Log message:
	Re-run failing tests with log/verbose=4 (-vvvv) to help with debugging.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/test/harness.c	2009/07/13 21:26:41	1.4
+++ LVM2/test/harness.c	2010/03/31 22:18:17	1.5
@@ -126,6 +126,9 @@
 int main(int argc, char **argv) {
 	int i;
 	status = alloca(sizeof(int)*argc);
+	char *config = getenv("LVM_TEST_CONFIG"),
+	     *config_debug;
+	asprintf(&config_debug, "%s\n%s", config ? config : "", "log {\n verbose=4\n }");
 
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");
@@ -149,6 +152,12 @@
 		run(i, argv[i]);
 		if (die)
 			break;
+		if ( status[i] == FAILED ) {
+			setenv("LVM_TEST_CONFIG", config_debug, 1);
+			run(i, argv[i]);
+			setenv("LVM_TEST_CONFIG", config, 1);
+			status[i] = FAILED; /* just in case */
+		}
 	}
 
 	printf("\n## %d tests: %d OK, %d failed, %d skipped\n",
--- LVM2/test/test-utils.sh	2010/03/28 15:52:04	1.26
+++ LVM2/test/test-utils.sh	2010/03/31 22:18:17	1.27
@@ -316,6 +316,7 @@
         locktype=
 	if test -n "$LVM_TEST_LOCKING"; then locktype="locking_type = $LVM_TEST_LOCKING"; fi
 	cat > $G_root_/etc/lvm.conf <<-EOF
+  $LVM_TEST_CONFIG
   devices {
     dir = "$G_dev_"
     scan = "$G_dev_"
@@ -324,7 +325,6 @@
     sysfs_scan = 0
   }
   log {
-    verbose = $verboselevel
     syslog = 0
     indent = 1
   }


