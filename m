From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 11:28:54 +0000 (UTC)
Subject: dev-mornfall-nix - test: Suffix result outputs with .txt to avoid mime type confusion.
Message-ID: <20130527112854.C52B560DB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20928cc3c0794be14e2da5108f64292764de55d2
Commit:        20928cc3c0794be14e2da5108f64292764de55d2
Parent:        dd392346cccffa33d98df99fcaa2af0f1f2e6965
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 13:28:22 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 13:28:22 2013 +0200

test: Suffix result outputs with .txt to avoid mime type confusion.

---
 test/lib/harness.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index b98839f..df4177a 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -313,7 +313,7 @@ static void run(int i, char *f) {
 		printf("Running %-50s ", buf);
 		fflush(stdout);
 		char outpath[512];
-		sprintf(outpath, "results/%s", f);
+		sprintf(outpath, "results/%s.txt", f);
 		while (strchr(outpath + 8, '/'))
 			*strchr(outpath + 8, '/') = '_';
 		if (outfile)


