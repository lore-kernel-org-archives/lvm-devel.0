From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:56:51 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20090806155651.23427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:56:51

Modified files:
	tools          : dmsetup.c 

Log message:
	Fix semaphore includes in dmsetup for udev sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/tools/dmsetup.c	2009/08/06 15:05:10	1.122
+++ LVM2/tools/dmsetup.c	2009/08/06 15:56:50	1.123
@@ -280,34 +280,6 @@
 	struct dm_split_name *split_name;
 };
 
-static char _yes_no_prompt(const char *prompt, ...)
-{
-	int c = 0, ret = 0;
-	va_list ap;
-
-	do {
-		if (c == '\n' || !c) {
-			va_start(ap, prompt);
-			vprintf(prompt, ap);
-			va_end(ap);
-		}
-
-		if ((c = getchar()) == EOF) {
-			ret = 'n';
-			break;
-		}
-
-		c = tolower(c);
-		if ((c == 'y') || (c == 'n'))
-			ret = c;
-	} while (!ret || c != '\n');
-
-	if (c != '\n')
-		printf("\n");
-
-	return ret;
-}
-
 static struct dm_task *_get_deps_task(int major, int minor)
 {
 	struct dm_task *dmt;
@@ -804,8 +776,41 @@
 	return 1;
 }
 
+static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	return 1;
+}
+
 #else
 
+static char _yes_no_prompt(const char *prompt, ...)
+{
+	int c = 0, ret = 0;
+	va_list ap;
+
+	do {
+		if (c == '\n' || !c) {
+			va_start(ap, prompt);
+			vprintf(prompt, ap);
+			va_end(ap);
+		}
+
+		if ((c = getchar()) == EOF) {
+			ret = 'n';
+			break;
+		}
+
+		c = tolower(c);
+		if ((c == 'y') || (c == 'n'))
+			ret = c;
+	} while (!ret || c != '\n');
+
+	if (c != '\n')
+		printf("\n");
+
+	return ret;
+}
+
 static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	int max_id, id, sid;
@@ -852,7 +857,6 @@
 
 	return 1;
 }
-#endif
 
 static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
@@ -891,7 +895,7 @@
 
 	return 1;
 }
-
+#endif
 
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {


