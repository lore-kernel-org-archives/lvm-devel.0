From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 15 May 2014 10:14:21 +0000 (UTC)
Subject: master - display: print skipped prompt
Message-ID: <20140515101421.BBD1E60DC4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11bedf1baf6dbc48c7abf9a14f8584d996d00a59
Commit:        11bedf1baf6dbc48c7abf9a14f8584d996d00a59
Parent:        76c06c72523201bdb478bd1735b2fcfbe49d3d38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 15 11:58:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 15 12:11:35 2014 +0200

display: print skipped prompt

Since decisions in the silent mode may not be always obvious,
print skipped prompt with answer 'n'.

Also document  '-qq' behaviour (single -q only shuts
logging, while -qq sets silent mode).
---
 WHATS_NEW             |    1 +
 lib/display/display.c |   10 ++++++----
 man/lvm.8.in          |    1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 090e914..5900bc6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Display skipped prompt in silent mode.
   Make reporting commands show help about possible sort keys on '-O help'.
   Add metadata_percent to lvs_cols.
   Take account of parity areas with alloc anywhere in _calc_required_extents.
diff --git a/lib/display/display.c b/lib/display/display.c
index b808f25..3c47aa8 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -880,9 +880,6 @@ char yes_no_prompt(const char *prompt, ...)
 	int c = 0, ret = 0;
 	va_list ap;
 
-	if (silent_mode())
-		return 'n';
-
 	sigint_allow();
 	do {
 		if (c == '\n' || !c) {
@@ -890,6 +887,11 @@ char yes_no_prompt(const char *prompt, ...)
 			vfprintf(stderr, prompt, ap);
 			va_end(ap);
 			fflush(stderr);
+			if (silent_mode()) {
+				fputc('n', stderr);
+				ret = 'n';
+				break;
+			}
 			ret = 0;
 		}
 
@@ -911,7 +913,7 @@ char yes_no_prompt(const char *prompt, ...)
 	sigint_restore();
 
 	if (c != '\n')
-		fprintf(stderr, "\n");
+		fputc('\n', stderr);
 
 	return ret;
 }
diff --git a/man/lvm.8.in b/man/lvm.8.in
index e273935..e1063c6 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -174,6 +174,7 @@ Overrides config file setting.
 .BR \-q ", "  \-\-quiet
 Suppress output and log messages.
 Overrides \fB\-d\fP and \fB\-v\fP.
+Repeat once to also suppress any prompts with answer 'no'.
 .TP
 .BR \-\-yes
 Don't prompt for confirmation interactively but instead always assume the


