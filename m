From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 11:25:47 +0000 (UTC)
Subject: dev-mornfall-nix - test: Do not fail when flavour overrides are empty.
Message-ID: <20130527112547.BCD5360319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd392346cccffa33d98df99fcaa2af0f1f2e6965
Commit:        dd392346cccffa33d98df99fcaa2af0f1f2e6965
Parent:        da087da6844f543c7c8dd12d4ac1bc6920ce41a8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 13:25:27 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 13:25:27 2013 +0200

test: Do not fail when flavour overrides are empty.

---
 test/lib/test.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/test.sh b/test/lib/test.sh
index 7b92814..daeefdd 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -57,6 +57,7 @@ cd "$TESTDIR"
 echo "$TESTNAME" >TESTNAME
 
 if test -n "$LVM_TEST_FLAVOUR"; then
+    touch flavour_overrides
     env | grep ^$LVM_TEST_FLAVOUR | while read var; do
 	(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
     done


