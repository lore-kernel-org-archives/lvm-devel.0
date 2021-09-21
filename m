From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:00 +0000 (GMT)
Subject: main - gcc-fanalyzer: helping understand answer is not null
Message-ID: <20210921195100.8973A3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=178df1c8f4aa6fa73f9f55f2a7f5f7b8c8c0964d
Commit:        178df1c8f4aa6fa73f9f55f2a7f5f7b8c8c0964d
Parent:        462ac47003e14975b91832f19bc287bd1a775bb4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:32:21 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

gcc-fanalyzer: helping understand answer is not null

gcc can't easily see pointer 'answer' is only being checked once 'ret > 0'.
---
 lib/display/display.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index f9c9ef836..3c2c2c2bc 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -974,7 +974,7 @@ char yes_no_prompt(const char *prompt, ...)
 
 		c = tolower(c);
 
-		if ((ret > 0) && (c == answer[0]))
+		if ((ret > 0) && answer && (c == answer[0]))
 			answer++;	/* Matching, next char */
 		else if (c == '\n') {
 			if (feof(stdin))
@@ -1000,7 +1000,7 @@ char yes_no_prompt(const char *prompt, ...)
 			/* Ignore any whitespace before */
 			--i;
 			goto nextchar;
-		} else if ((ret > 0) && isspace(c)) {
+		} else if ((ret > 0) && answer && isspace(c)) {
 			/* Ignore any whitespace after */
 			while (*answer)
 				answer++; /* jump to end-of-word */


