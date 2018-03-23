From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:47 -0400
Subject: master - tests: shellcheck prevention check
Message-ID: <201803231625.w2NGPlFZ031939@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14abe1e87b85ebaf254d81f6ee98d10ae21d79ce
Commit:        14abe1e87b85ebaf254d81f6ee98d10ae21d79ce
Parent:        cafcc5813ac958798d5dce19b1b65a9941cc39ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 16:58:48 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: shellcheck prevention check

Always make sure variable is set to something else the /dev/*
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a7ad60a..43dfa50 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -399,7 +399,7 @@ teardown_devs_prefixed() {
 	local once=1
 	local dm
 
-	rm -rf "$TESTDIR/dev/$prefix*"
+	rm -rf "${TESTDIR:?}/dev/$prefix*"
 
 	# Send idle message to frozen raids (with hope to unfreeze them)
 	for dm in $(dm_status | egrep "$prefix.*raid.*frozen"); do


