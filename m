From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 14:47:25 -0000
Subject: LVM2/test/lib harness.c
Message-ID: <20110310144725.22748.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 14:47:23

Modified files:
	test/lib       : harness.c 

Log message:
	Indent spaces to tabs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/lib/harness.c	2011/01/28 16:05:38	1.6
+++ LVM2/test/lib/harness.c	2011/03/10 14:47:22	1.7
@@ -44,8 +44,8 @@
 static int verbose = 0;
 
 struct subst {
-        const char *key;
-        char *value;
+	const char *key;
+	char *value;
 };
 
 static struct subst subst[2];
@@ -62,52 +62,52 @@
 }
 
 static int outline(char *buf, int start, int force) {
-        char *from = buf + start;
-        char *next = strchr(buf + start, '\n');
+	char *from = buf + start;
+	char *next = strchr(buf + start, '\n');
 
-        if (!next && !force) /* not a complete line yet... */
-                return start;
+	if (!next && !force) /* not a complete line yet... */
+		return start;
 
-        if (!next)
-                next = from + strlen(from);
-        else
-                ++next;
-
-        if (!strncmp(from, "@TESTDIR=", 9)) {
-                subst[0].key = "@TESTDIR@";
-                subst[0].value = strndup(from + 9, next - from - 9 - 1);
-        } else if (!strncmp(from, "@PREFIX=", 8)) {
-                subst[1].key = "@PREFIX@";
-                subst[1].value = strndup(from + 8, next - from - 8 - 1);
-        } else {
-                char *line = strndup(from, next - from);
-                char *a = line, *b;
-                do {
-                        int idx = -1;
-                        int i;
-                        b = line + strlen(line);
-                        for ( i = 0; i < 2; ++i ) {
-                                if (subst[i].key) {
-                                        // printf("trying: %s -> %s\n", subst[i].value, subst[i].key);
-                                        char *stop = strstr(a, subst[i].value);
-                                        if (stop && stop < b) {
-                                                idx = i;
-                                                b = stop;
-                                        }
-                                }
-                        }
-                        fwrite(a, 1, b - a, stdout);
-                        a = b;
-
-                        if ( idx >= 0 ) {
-                                fprintf(stdout, "%s", subst[idx].key);
-                                a += strlen(subst[idx].value);
-                        }
-                } while (b < line + strlen(line));
-                free(line);
-        }
+	if (!next)
+		next = from + strlen(from);
+	else
+		++next;
+
+	if (!strncmp(from, "@TESTDIR=", 9)) {
+		subst[0].key = "@TESTDIR@";
+		subst[0].value = strndup(from + 9, next - from - 9 - 1);
+	} else if (!strncmp(from, "@PREFIX=", 8)) {
+		subst[1].key = "@PREFIX@";
+		subst[1].value = strndup(from + 8, next - from - 8 - 1);
+	} else {
+		char *line = strndup(from, next - from);
+		char *a = line, *b;
+		do {
+			int idx = -1;
+			int i;
+			b = line + strlen(line);
+			for ( i = 0; i < 2; ++i ) {
+				if (subst[i].key) {
+					// printf("trying: %s -> %s\n", subst[i].value, subst[i].key);
+					char *stop = strstr(a, subst[i].value);
+					if (stop && stop < b) {
+						idx = i;
+						b = stop;
+					}
+				}
+			}
+			fwrite(a, 1, b - a, stdout);
+			a = b;
+
+			if ( idx >= 0 ) {
+				fprintf(stdout, "%s", subst[idx].key);
+				a += strlen(subst[idx].value);
+			}
+		} while (b < line + strlen(line));
+		free(line);
+	}
 
-        return next - buf + (force ? 0 : 1);
+	return next - buf + (force ? 0 : 1);
 }
 
 static void dump(void) {
@@ -126,7 +126,7 @@
 static void drain(void) {
 	int sz;
 	char buf[2048];
-        memset(buf, 0, 2048);
+	memset(buf, 0, 2048);
 
 	while (1) {
 		sz = read(fds[1], buf, 2047);
@@ -195,8 +195,8 @@
 		close(0);
 		dup2(fds[0], 1);
 		dup2(fds[0], 2);
-                close(fds[0]);
-                close(fds[1]);
+		close(fds[0]);
+		close(fds[1]);
 		execlp("bash", "bash", f, NULL);
 		perror("execlp");
 		fflush(stderr);
@@ -257,11 +257,11 @@
 	}
 
 	/* set up signal handlers */
-        for (i = 0; i <= 32; ++i) {
-            if (i == SIGCHLD || i == SIGWINCH || i == SIGURG)
-                continue;
-            signal(i, handler);
-        }
+	for (i = 0; i <= 32; ++i) {
+		if (i == SIGCHLD || i == SIGWINCH || i == SIGURG)
+			continue;
+		signal(i, handler);
+	}
 
 	/* run the tests */
 	for (i = 1; i < argc; ++ i) {


