From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Nov 2011 01:34:39 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20111123013439.5790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-23 01:34:38

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
	
	(Note that in a future release we might make this stricter and insist
	on exactly 'y' or 'n'.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2195&r2=1.2196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/WHATS_NEW	2011/11/21 12:44:38	1.2195
+++ LVM2/WHATS_NEW	2011/11/23 01:34:38	1.2196
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
   Replace the unit testing framework with CUnit (--enable-testing).
   Fix dmeventd snapshot monitoring when multiple extensions were involved.
   Don't ignore configure --mandir and --infodir.
--- LVM2/lib/display/display.c	2011/10/04 12:39:59	1.121
+++ LVM2/lib/display/display.c	2011/11/23 01:34:38	1.122
@@ -850,9 +850,10 @@
 	do {
 		if (c == '\n' || !c) {
 			va_start(ap, prompt);
-			vprintf(prompt, ap);
+			vfprintf(stderr, prompt, ap);
 			va_end(ap);
-			fflush(stdout);
+			fflush(stderr);
+			ret = 0;
 		}
 
 		if ((c = getchar()) == EOF) {
@@ -861,9 +862,14 @@
 		}
 
 		c = tolower(c);
-		if ((c == 'y') || (c == 'n'))
-			ret = c;
-	} while (!ret || c != '\n');
+		if ((c == 'y') || (c == 'n')) {
+			/* If both 'y' and 'n' given, begin again. */
+			if (ret && c != ret)
+				ret = -1;
+			else
+				ret = c;
+		}
+	} while (ret < 1 || c != '\n');
 
 	sigint_restore();
 


