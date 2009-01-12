From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Jan 2009 18:45:45 -0000
Subject: LVM2/test Makefile.in test-utils.sh not.c
Message-ID: <20090112184545.13175.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-01-12 18:45:44

Modified files:
	test           : Makefile.in test-utils.sh 
Added files:
	test           : not.c 

Log message:
	A C implementation of "not" that handles fatal signals rather more
	intelligently than the shell implementation. C code by Jaroslav Stava.
	
	I have done a rudimentary review and checked that tests still pass.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

/cvs/lvm2/LVM2/test/not.c,v  -->  standard output
revision 1.1
--- LVM2/test/not.c
+++ -	2009-01-12 18:45:44.824917000 +0000
@@ -0,0 +1,36 @@
+#include <unistd.h>
+#include <stdio.h>
+#include <stdarg.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+int main(int args, char **argv) {
+	pid_t pid;
+	int status;
+	int FAILURE = 6;
+
+	if (args < 2) {
+		fprintf(stderr, "Need args\n");
+		return FAILURE;
+	}
+
+	pid = fork();
+	if (pid == -1) {
+		fprintf(stderr, "Could not fork\n");
+		return FAILURE;
+	} else if (pid == 0) { 	/* child */
+		execvp(argv[1], &argv[1]);
+		/* should not be accessible */
+		return FAILURE;
+	} else {		/* parent */
+		waitpid(pid, &status, 0);
+		if (!WIFEXITED(status)) {
+			/* did not exit correctly */
+			return FAILURE;
+		}
+		/* return the opposite */
+		return !WEXITSTATUS(status);
+	}
+	/* not accessible */
+	return FAILURE;
+}
--- LVM2/test/Makefile.in	2008/11/07 01:30:03	1.14
+++ LVM2/test/Makefile.in	2009/01/12 18:45:44	1.15
@@ -25,9 +25,12 @@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
-all: init.sh
+all: bin/not init.sh
 	sh harness.sh
 
+bin/not: .bin-dir-stamp
+	$(CC) -o bin/not not.c
+
 init.sh: Makefile.in .bin-dir-stamp
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
@@ -49,7 +52,7 @@
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-$(T): init.sh
+$(T): bin/not init.sh
 	sh harness.sh $@
 
 .bin-dir-stamp: lvm-wrapper
--- LVM2/test/test-utils.sh	2009/01/09 10:16:57	1.9
+++ LVM2/test/test-utils.sh	2009/01/12 18:45:44	1.10
@@ -17,16 +17,6 @@
 	#"$@"
 }
 
-not () {
-	"$@" && exit 1 || {
-		err="$?"
-		if test "$err" = 129; then
-			echo "fatal error $err"
-			exit 1
-		fi
-	}
-}
-
 STACKTRACE() {
 	trap - ERR;
 	i=0;


