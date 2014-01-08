From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Jan 2014 16:14:53 +0000 (UTC)
Subject: master - test: Increase the overall timeout to 3 hours.
Message-ID: <20140108161453.D7F3460E0F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e892ac73980db349deeb3ff6863bd8e3b5727654
Commit:        e892ac73980db349deeb3ff6863bd8e3b5727654
Parent:        d52c4154c5e9d300cbee96231f0b95fa416453bf
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Dec 16 17:35:33 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 8 17:11:32 2014 +0100

test: Increase the overall timeout to 3 hours.

---
 test/lib/harness.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 9613543..ded86f0 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -550,9 +550,9 @@ int main(int argc, char **argv) {
 	/* run the tests */
 	for (i = 1; !die && i < argc; ++i) {
 		run(i, argv[i]);
-		if ( time(NULL) - harness_start > 3600 ) {
-			printf("an hour passed, giving up...\n");
-			break;
+		if ( time(NULL) - harness_start > 3 * 3600 ) {
+			printf("3 hours passed, giving up...\n");
+			die = 1;
 		}
 	}
 


