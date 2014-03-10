From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:19 +0000 (UTC)
Subject: master - cleanup: dmeventd convert multiline to single line
Message-ID: <20140310112719.65EE1603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d080abf7d60fc23343670e444d4cd26745e3e5d5
Commit:        d080abf7d60fc23343670e444d4cd26745e3e5d5
Parent:        7b17dfed69e50eabdc288f48a2fde16d4000709f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 09:45:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

cleanup: dmeventd convert multiline to single line

Instead of doing multiple different calls, select
stream within a condition.

Replace fprintf with fputc for '\n'
---
 daemons/dmeventd/dmeventd.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 343180d..6206058 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -632,18 +632,10 @@ static void _no_intr_log(int level, const char *file, int line,
 		return;
 
 	va_start(ap, f);
-
-	if (level < _LOG_WARN)
-		vfprintf(stderr, f, ap);
-	else
-		vprintf(f, ap);
-
+	vfprintf((level < _LOG_WARN) ? stderr : stdout, f, ap);
 	va_end(ap);
 
-	if (level < _LOG_WARN)
-		fprintf(stderr, "\n");
-	else
-		fprintf(stdout, "\n");
+	fputc('\n', (level < _LOG_WARN) ? stderr : stdout);
 }
 
 static sigset_t _unblock_sigalrm(void)


