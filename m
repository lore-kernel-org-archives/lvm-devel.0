From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 10 Jun 2016 14:03:57 +0000 (UTC)
Subject: master - display: yes no prompt improvement
Message-ID: <20160610140357.A8B6A61B9F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35612bd27c203774948c84005c9fb9237746c34a
Commit:        35612bd27c203774948c84005c9fb9237746c34a
Parent:        cfdc87b62331875c2f10cca2c41f486d40b2a67c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 8 20:52:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 10 16:00:31 2016 +0200

display: yes no prompt improvement

Original code missed to catch all apperances of SIGINT.
Also enhance logging when running in shell without tty.
Accept this regex as valid input:
'^[ ^t]*([Yy]([Ee]([Ss]|)|)|[Nn]([Oo]|))[ ^t]*$'
---
 WHATS_NEW             |    1 +
 lib/display/display.c |  100 +++++++++++++++++++++++++++++++++++++------------
 2 files changed, 77 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0afd527..0f8ebda 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.156 - 
 ================================
+  Yes/No prompt accepts '^[ ^t]*([Yy]([Ee]([Ss]|)|)|[Nn]([Oo]|))[ ^t]*$'.
   If available, also collect output from lsblk command when running lvmdump -s.
   Fix regression in blkdeactivate causing dm and md devices to be skipped. (2.02.155)
 
diff --git a/lib/display/display.c b/lib/display/display.c
index 0151d01..19421e7 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -831,50 +831,102 @@ void display_name_error(name_error_t name_error)
  * Prompt for y or n from stdin.
  * Defaults to 'no' in silent mode.
  * All callers should support --yes and/or --force to override this.
+ *
+ * Accepted are either _yes[] or _no[] strings or just their outset.
+ * When running without 'tty' stdin is printed to stderr.
+ * 'Yes' is accepted ONLY with '\n'.
  */
 char yes_no_prompt(const char *prompt, ...)
 {
-	int c = 0, ret = 0, cb = 0;
+	/* Lowercase Yes/No strings */
+	static const char _yes[] = "yes";
+	static const char _no[] = "no";
+	const char *answer = NULL;
+	int c = silent_mode() ? EOF : 0;
+	int i, ret = 0, sig = 0;
+	char buf[12];
 	va_list ap;
 
 	sigint_allow();
-	do {
-		if (c == '\n' || !c) {
+
+	for (;;) {
+		if (!ret) {
+			/* Show prompt */
 			va_start(ap, prompt);
 			vfprintf(stderr, prompt, ap);
 			va_end(ap);
 			fflush(stderr);
-			if (silent_mode()) {
-				fputc('n', stderr);
-				ret = 'n';
+
+			if (c == EOF)
 				break;
-			}
-			ret = 0;
+
+			i = 0;
+			answer = NULL;
 		}
 
+	nextchar:
+		if ((sig = sigint_caught()))
+			break;	/* Check if already interrupted before getchar() */
+
 		if ((c = getchar()) == EOF) {
-			ret = 'n'; /* SIGINT */
-			cb = 1;
-			break;
+			/* SIGNAL or no chars on stdin (missing '\n') or ^D */
+			if (!i)
+				break; /* Just shown prompt,-> print [n]\n */
+
+			goto invalid; /* Note:  c holds EOF */
 		}
 
+		if ((i < (sizeof(buf) - 4)) && isprint(c))
+			buf[i++] = c;
+
 		c = tolower(c);
-		if ((c == 'y') || (c == 'n')) {
-			/* If both 'y' and 'n' given, begin again. */
-			if (ret && c != ret)
-				ret = -1;
-			else
-				ret = c;
-		}
-	} while (ret < 1 || c != '\n');
 
-	sigint_restore();
+		if ((ret > 0) && (c == answer[0]))
+			answer++;	/* Matching, next char */
+		else if (c == '\n') {
+			if (feof(stdin))
+				fputc('\n', stderr);
+			if (ret > 0)
+				break;	/* Answered */
+	invalid:
+			if (i >= (sizeof(buf) - 4)) {
+				/* '...'  for missing input */
+				i = sizeof(buf) - 1;
+				buf[i - 1] = buf[i - 2] = buf[i - 3] = '.';
+			}
+			buf[i] = 0;
+			log_warn("WARNING: Invalid input '%s'.", buf);
+			ret = 0;	/* Otherwise refresh prompt */
+		} else if (!ret && (c == _yes[0])) {
+			ret = 'y';
+			answer = _yes + 1;	/* Expecting 'Yes' */
+		} else if (!ret && (c == _no[0])) {
+			ret = 'n';
+			answer = _no + 1;	/* Expecting 'No' */
+		} else if (!ret && isspace(c)) {
+			/* Ignore any whitespace before */
+			--i;
+			goto nextchar;
+		} else if ((ret > 0) && isspace(c)) {
+			/* Ignore any whitespace after */
+			while (*answer)
+				answer++; /* jump to end-of-word */
+		} else
+			ret = -1;	/* Read till '\n' and refresh */
+	}
 
-	if (cb && !sigint_caught())
-		fputc(ret, stderr);
+	sigint_restore();
 
-	if (c != '\n')
-		fputc('\n', stderr);
+	/* For other then Yes answer check there is really no interrupt */
+	if (sig || sigint_caught()) {
+		stack;
+		ret = 'n';
+	} else if (c == EOF) {
+		fputs("[n]\n", stderr);
+		ret = 'n';
+	} else
+		/* Not knowing if it's terminal, makes this hard.... */
+		log_verbose("Accepted input: [%c]", ret);
 
 	return ret;
 }


