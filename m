From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Dec 2013 10:22:03 +0000 (UTC)
Subject: master - tests: count interrupted test as failed
Message-ID: <20131210102203.0A2BE610F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9fe05eee26596feb7ed7e83e3da96b8efcbdb20
Commit:        c9fe05eee26596feb7ed7e83e3da96b8efcbdb20
Parent:        e3b7fa4b8d310ffc14ed10039caf43e1a9140f64
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 11:21:40 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 11:21:40 2013 +0100

tests: count interrupted test as failed

---
 test/lib/harness.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index c4dd3da..fa174bb 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -538,12 +538,12 @@ int main(int argc, char **argv) {
 	free(subst[1].value);
 	free(readbuf);
 
-	printf("\n## %d tests %s : %d OK, %d warnings, %d failures, %d known failures; "
-	       "%d skipped, %d interrupted\n",
+	printf("\n## %d tests %s : %d OK, %d warnings, %d failures (%d interrupted), %d known failures; "
+	       "%d skipped\n",
 	       s.nwarned + s.npassed + s.nfailed + s.nskipped + s.ninterrupted,
 	       duration(start, NULL),
-	       s.npassed, s.nwarned, s.nfailed, s.nknownfail,
-	       s.nskipped, s.ninterrupted);
+	       s.npassed, s.nwarned, s.nfailed + s.ninterrupted, s.ninterrupted,
+	       s.nknownfail, s.nskipped);
 
 	/* dump a list to results */
 	if ((list = fopen(results_list, "w"))) {


