From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 11:25:07 +0000 (UTC)
Subject: master - tests: Revert "tests: not redirect strderr to stdout"
Message-ID: <20160913112507.DB45E610BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=629059ee84e83b9d013d80e0b382a3474b30c7a4
Commit:        629059ee84e83b9d013d80e0b382a3474b30c7a4
Parent:        cebcc8a6040e44223e466572ee899c591b42e5d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 13:23:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 13:23:47 2016 +0200

tests: Revert "tests: not redirect strderr to stdout"

This reverts commit 5314d36f3d186efb05a051e80444332f743194ef.

Ok - some tests do look for 'stderr' output of 'not' commands.
So let's keep existing functionality.
---
 test/lib/not.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/test/lib/not.c b/test/lib/not.c
index 4ce77b6..a5c52a8 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -72,12 +72,9 @@ int main(int args, char **argv) {
 		fprintf(stderr, "Could not fork\n");
 		return FAILURE;
 	} else if (pid == 0) { 	/* child */
-		if (!strcmp(argv[0], "not")) {
+		if (!strcmp(argv[0], "not"))
 			val = ">1";
-			/* Redirect 'expected' error output */
-			fflush(stderr);
-			dup2(fileno(stdout), fileno(stderr));
-		} else if (!strcmp(argv[0], "invalid"))
+		else if (!strcmp(argv[0], "invalid"))
 			val = "3";
 		else if (!strcmp(argv[0], "fail"))
 			val = "5";


