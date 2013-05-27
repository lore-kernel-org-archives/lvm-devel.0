From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 14:04:04 +0000 (UTC)
Subject: dev-mornfall-nix - test: Avoid a leaked fd when exec'ing tests.
Message-ID: <20130527140404.C575960DFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea56a7ea612cf9230307e65ef0bb62c7a0f66df0
Commit:        ea56a7ea612cf9230307e65ef0bb62c7a0f66df0
Parent:        2412716f1726aefcc57be3e2d8ca6f6f8b15b743
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 15:52:11 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 15:52:11 2013 +0200

test: Avoid a leaked fd when exec'ing tests.

---
 test/lib/harness.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index df4177a..e80efbf 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -316,8 +316,6 @@ static void run(int i, char *f) {
 		sprintf(outpath, "results/%s.txt", f);
 		while (strchr(outpath + 8, '/'))
 			*strchr(outpath + 8, '/') = '_';
-		if (outfile)
-			fclose(outfile);
 		outfile = fopen(outpath, "w");
 		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
 			drain();
@@ -340,6 +338,7 @@ static void run(int i, char *f) {
 			failed(i, f, st);
 		}
 		clear();
+		fclose(outfile);
 	}
 }
 


