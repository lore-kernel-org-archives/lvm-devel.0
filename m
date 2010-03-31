From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Mar 2010 23:11:13 -0000
Subject: LVM2/test harness.c
Message-ID: <20100331231113.12075.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-31 23:11:13

Modified files:
	test           : harness.c 

Log message:
	Do not pass NULL to setenv in the test harness.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/harness.c	2010/03/31 22:18:17	1.5
+++ LVM2/test/harness.c	2010/03/31 23:11:12	1.6
@@ -128,7 +128,8 @@
 	status = alloca(sizeof(int)*argc);
 	char *config = getenv("LVM_TEST_CONFIG"),
 	     *config_debug;
-	asprintf(&config_debug, "%s\n%s", config ? config : "", "log {\n verbose=4\n }");
+	config = config ? config : "";
+	asprintf(&config_debug, "%s\n%s\n", config, "log { verbose=4 }");
 
 	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
 		perror("socketpair");


