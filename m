From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Feb 2009 19:54:54 -0000
Subject: LVM2/test Makefile.in harness.c
Message-ID: <20090212195454.24524.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-02-12 19:54:51

Modified files:
	test           : Makefile.in 
Added files:
	test           : harness.c 

Log message:
	Re-implement the test harness in C. This lets us pass through signals and
	trigger proper test teardown upon harness interrupt or termination. I also
	tweaked the output somewhat while I was at it...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

/cvs/lvm2/LVM2/test/harness.c,v  -->  standard output
revision 1.1
--- LVM2/test/harness.c
+++ -	2009-02-12 19:54:51.984403000 +0000
@@ -0,0 +1,171 @@
+#include <fcntl.h>
+#include <string.h>
+#include <stdio.h>
+#include <sys/socket.h>
+#include <sys/wait.h>
+#include <unistd.h>
+#include <stdlib.h>
+
+pid_t pid;
+int fds[2];
+int *status;
+int nfailed = 0;
+int nskipped = 0;
+int npassed = 0;
+
+char *readbuf = NULL;
+int readbuf_sz = 0, readbuf_used = 0;
+
+int die = 0;
+
+#define PASSED 0
+#define SKIPPED 1
+#define FAILED 2
+
+void handler( int s ) {
+	signal( s, SIG_DFL );
+	kill( pid, s );
+	die = s;
+}
+
+void dump() {
+	write(1, readbuf, readbuf_used);
+}
+
+void clear() {
+	readbuf_used = 0;
+}
+
+void drain() {
+	int sz;
+	char buf[2048];
+	while (1) {
+		sz = read(fds[1], buf, 2048);
+		if (sz <= 0)
+			return;
+		if (readbuf_used + sz >= readbuf_sz) {
+			readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
+			readbuf = realloc(readbuf, readbuf_sz);
+		}
+		if (!readbuf)
+			exit(205);
+		memcpy(readbuf + readbuf_used, buf, sz);
+		readbuf_used += sz;
+	}
+}
+
+void passed(int i, char *f) {
+	++ npassed;
+	status[i] = PASSED;
+	printf("passed.\n");
+}
+
+void skipped(int i, char *f) {
+	++ nskipped;
+	status[i] = SKIPPED;
+	printf("skipped.\n");
+}
+
+void failed(int i, char *f, int st) {
+	++ nfailed;
+	status[i] = FAILED;
+	if(die == 2) {
+		printf("interrupted.\n");
+		return;
+	}
+	printf("FAILED.\n");
+	printf("-- FAILED %s ------------------------------------\n", f);
+	dump();
+	printf("-- FAILED %s (end) ------------------------------\n", f);
+}
+
+void run(int i, char *f) {
+	pid = fork();
+	if (pid < 0) {
+		perror("Fork failed.");
+		exit(201);
+	} else if (pid == 0) {
+		close(0);
+		dup2(fds[0], 1);
+		dup2(fds[0], 2);
+		execlp("bash", "bash", f, NULL);
+		perror("execlp");
+		exit(202);
+	} else {
+		char buf[128];
+		snprintf(buf, 128, "%s ...", f);
+		buf[127] = 0;
+		printf("Running %-40s ", buf);
+		fflush(stdout);
+		int st, w;
+		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+			drain();
+			usleep(20000);
+		}
+		if (w != pid) {
+			perror("waitpid");
+			exit(206);
+		}
+		if (WIFEXITED(st)) {
+			if (WEXITSTATUS(st) == 0) {
+				passed(i, f);
+			} else if (WEXITSTATUS(st) == 200) {
+				skipped(i, f);
+			} else {
+				failed(i, f, st);
+			}
+		} else {
+			failed(i, f, st);
+		}
+		clear();
+	}
+}
+
+int main(int argc, char **argv) {
+	int i;
+	status = alloca(sizeof(int)*argc);
+
+	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
+		perror("socketpair");
+		return 201;
+	}
+
+        if ( fcntl( fds[1], F_SETFL, O_NONBLOCK ) == -1 ) {
+		perror("fcntl on socket");
+		return 202;
+	}
+
+	/* set up signal handlers */
+        for (i = 0; i <= 32; ++i) {
+            if (i == SIGCHLD || i == SIGWINCH || i == SIGURG)
+                continue;
+            signal(i, handler);
+        }
+
+	/* run the tests */
+	for (i = 1; i < argc; ++ i) {
+		run(i, argv[i]);
+		if (die)
+			break;
+	}
+
+	printf("\n## %d tests: %d OK, %d failed, %d skipped\n",
+	       npassed + nfailed + nskipped, npassed, nfailed, nskipped);
+
+	/* print out a summary */
+	if (nfailed || nskipped ) {
+		for (i = 1; i < argc; ++ i) {
+			switch (status[i]) {
+			case FAILED:
+				printf("FAILED: %s\n", argv[i]);
+				break;
+			case SKIPPED:
+				printf("skipped: %s\n", argv[i]);
+				break;
+			}
+		}
+		printf("\n");
+		return 1;
+	}
+	return !die;
+}
--- LVM2/test/Makefile.in	2009/01/12 18:45:44	1.15
+++ LVM2/test/Makefile.in	2009/02/12 19:54:45	1.16
@@ -25,13 +25,16 @@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
-all: bin/not init.sh
-	sh harness.sh
+all: init.sh
+	./bin/harness $(T)
 
-bin/not: .bin-dir-stamp
+bin/not: .bin-dir-stamp not.c
 	$(CC) -o bin/not not.c
 
-init.sh: Makefile.in .bin-dir-stamp
+bin/harness: .bin-dir-stamp harness.c
+	$(CC) -o bin/harness harness.c
+
+init.sh: Makefile.in .bin-dir-stamp bin/not bin/harness
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
@@ -52,8 +55,8 @@
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-$(T): bin/not init.sh
-	sh harness.sh $@
+$(T): init.sh
+	./bin/harness $@
 
 .bin-dir-stamp: lvm-wrapper
 	rm -rf bin


