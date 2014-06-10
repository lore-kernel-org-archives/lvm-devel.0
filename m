From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Jun 2014 08:52:05 +0000 (UTC)
Subject: master - tests: make timeouts longer
Message-ID: <20140610085205.A1D8360A38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f68aadb742b9cbd70c5cf5d750b64ff534bc8b3
Commit:        9f68aadb742b9cbd70c5cf5d750b64ff534bc8b3
Parent:        9f9a196dc0ca12a7bbb98d2e1dd66bb5603f7226
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 6 17:36:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 10 10:51:26 2014 +0200

tests: make timeouts longer

Add more time for tests, since debug kernels are getting slower...
and we add more and more tests.

However many test should be shortened to avoid testing disk-perfomance
and focus on lvm functionality...
(Often we should probably test with inactive volumes when we check
metadata operation of lvm2)

We may need to support option for 'DEEP' longer testing.

Also something like LVM_TEST_TIMEOUT_FACTOR might be useful
though it would be much better if test suite could approximete
from system perfomance test lenght...
---
 test/lib/aux.sh    |    2 +-
 test/lib/harness.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3ececaf..f6f0d0b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -750,7 +750,7 @@ udev_wait() {
 # wait_for_sync <VG/LV>
 wait_for_sync() {
 	local i
-	for i in {1..500} ; do
+	for i in {1..3000} ; do
 		check in_sync $1 $2 && return
 		sleep .2
 	done
diff --git a/test/lib/harness.c b/test/lib/harness.c
index d7e51ee..5b08255 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -585,8 +585,8 @@ int main(int argc, char **argv) {
 	/* run the tests */
 	for (i = 1; !die && i < argc; ++i) {
 		run(i, argv[i]);
-		if ( time(NULL) - harness_start > 3 * 3600 ) {
-			printf("3 hours passed, giving up...\n");
+		if ( time(NULL) - harness_start > 48 * 360 ) { /* 04:48 */
+			printf("Nearly 5 hours passed, giving up...\n");
 			die = 1;
 		}
 	}


