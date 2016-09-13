From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 10:26:07 +0000 (UTC)
Subject: master - tests: not redirect strderr to stdout
Message-ID: <20160913102607.8A6B7610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5314d36f3d186efb05a051e80444332f743194ef
Commit:        5314d36f3d186efb05a051e80444332f743194ef
Parent:        a156fc9a5431cef6a3435e796da6eac4d34c905f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 11:55:08 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 12:25:06 2016 +0200

tests: not redirect strderr to stdout

Errors are 'wanted' and expected in this case.
---
 test/lib/not.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/lib/not.c b/test/lib/not.c
index a5c52a8..4ce77b6 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -72,9 +72,12 @@ int main(int args, char **argv) {
 		fprintf(stderr, "Could not fork\n");
 		return FAILURE;
 	} else if (pid == 0) { 	/* child */
-		if (!strcmp(argv[0], "not"))
+		if (!strcmp(argv[0], "not")) {
 			val = ">1";
-		else if (!strcmp(argv[0], "invalid"))
+			/* Redirect 'expected' error output */
+			fflush(stderr);
+			dup2(fileno(stdout), fileno(stderr));
+		} else if (!strcmp(argv[0], "invalid"))
 			val = "3";
 		else if (!strcmp(argv[0], "fail"))
 			val = "5";


