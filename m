From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:09 +0000 (UTC)
Subject: master - prompt: display 'n' for EOF
Message-ID: <20140711113409.6624761133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baf825331cb37fd29007e7ed7596fb3683c8b37d
Commit:        baf825331cb37fd29007e7ed7596fb3683c8b37d
Parent:        39cb8aa3abd4e3eea7bbbdcc24225e8475c3aff3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 21:03:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:47:41 2014 +0200

prompt: display 'n' for EOF

When EOF is detect - it could be either 'Ctrl+C'
or empty stdin.

For Ctrl+C there is visual ^C sign.
For EOF print 'n' so decision is clear in debug print.
---
 lib/display/display.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index cd204a0..cfd83c9 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -883,7 +883,7 @@ void display_name_error(name_error_t name_error)
  */
 char yes_no_prompt(const char *prompt, ...)
 {
-	int c = 0, ret = 0;
+	int c = 0, ret = 0, cb = 0;
 	va_list ap;
 
 	sigint_allow();
@@ -903,6 +903,7 @@ char yes_no_prompt(const char *prompt, ...)
 
 		if ((c = getchar()) == EOF) {
 			ret = 'n'; /* SIGINT */
+			cb = 1;
 			break;
 		}
 
@@ -918,6 +919,9 @@ char yes_no_prompt(const char *prompt, ...)
 
 	sigint_restore();
 
+	if (cb && !sigint_caught())
+		fputc(ret, stderr);
+
 	if (c != '\n')
 		fputc('\n', stderr);
 


