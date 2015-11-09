From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 11:29:09 +0000 (UTC)
Subject: master - tests: do not skip test when delay is missing
Message-ID: <20151109112909.841DC60E09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab4773671b1738abb4fb6c1504fcdd953760d80b
Commit:        ab4773671b1738abb4fb6c1504fcdd953760d80b
Parent:        e4c9b390ca9cb1cb847c714f9b08558e9a405ea5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 12:14:42 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 12:21:17 2015 +0100

tests: do not skip test when delay is missing

Rather then skipping whole test - just do not use it.

Failing tests that have required delay need to deal with reality
and shell either check for HAVE_DM_DELAY and skip portion
of test or using should when needed.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3f99357..2c66f29 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -668,7 +668,7 @@ common_dev_() {
 # i.e.  delay_dev "$dev1" 0 200 256:
 delay_dev() {
 	if test ! -f HAVE_DM_DELAY ; then
-		target_at_least dm-delay 1 1 0 || skip
+		target_at_least dm-delay 1 1 0 || return 0
 	fi
 	touch HAVE_DM_DELAY
 	common_dev_ delay "$@"


