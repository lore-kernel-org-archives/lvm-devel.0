From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:30 +0000 (UTC)
Subject: master - tests: put test envvar into braces
Message-ID: <20140317133330.C032260EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a0fea104b4d0d81f8fc6edd2802e025a9172d41
Commit:        1a0fea104b4d0d81f8fc6edd2802e025a9172d41
Parent:        95f74af404411eff55f9e63dbb349adfac94dd59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 09:35:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:45 2014 +0100

tests: put test envvar into braces

Ensure we not fail on space.
---
 test/lib/test.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/test.sh b/test/lib/test.sh
index d7f6111..3bde1e3 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -42,7 +42,7 @@ cd "$TESTDIR"
 
 if test -n "$LVM_TEST_FLAVOUR"; then
 	touch flavour_overrides
-	env | grep ^$LVM_TEST_FLAVOUR | while read var; do
+	env | grep ^${LVM_TEST_FLAVOUR} | while read var; do
 		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
 	done
 	. flavour_overrides


