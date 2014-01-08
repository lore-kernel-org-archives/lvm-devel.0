From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Jan 2014 16:14:51 +0000 (UTC)
Subject: master - test: Time out the entire testsuite after an hour.
Message-ID: <20140108161451.BF89160E0F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d52c4154c5e9d300cbee96231f0b95fa416453bf
Commit:        d52c4154c5e9d300cbee96231f0b95fa416453bf
Parent:        af8580d756d3d4ed56a00d377fd6bfb18d5bed41
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Dec 16 11:47:09 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 8 17:11:32 2014 +0100

test: Time out the entire testsuite after an hour.

---
 test/lib/harness.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 19859a0..9613543 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -59,6 +59,8 @@ static const char *results;
 static unsigned fullbuffer = 0;
 static int unlimited = 0;
 
+static time_t harness_start;
+
 static FILE *outfile = NULL;
 char testdirdebug[PATH_MAX];
 
@@ -544,9 +546,15 @@ int main(int argc, char **argv) {
 		default: signal(i, handler);
 		}
 
+	harness_start = time(NULL);
 	/* run the tests */
-	for (i = 1; !die && i < argc; ++i)
+	for (i = 1; !die && i < argc; ++i) {
 		run(i, argv[i]);
+		if ( time(NULL) - harness_start > 3600 ) {
+			printf("an hour passed, giving up...\n");
+			break;
+		}
+	}
 
 	free(subst[0].value);
 	free(subst[1].value);


