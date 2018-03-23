From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:53 -0400
Subject: master - tests: shellcheck use grep -E
Message-ID: <201803231625.w2NGPrUR031963@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=410c99274418f0ce184f670522939ff14a06217f
Commit:        410c99274418f0ce184f670522939ff14a06217f
Parent:        14abe1e87b85ebaf254d81f6ee98d10ae21d79ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 16:59:51 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: shellcheck use grep -E

Replace egrep with grep -E
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 43dfa50..a22f858 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -402,7 +402,7 @@ teardown_devs_prefixed() {
 	rm -rf "${TESTDIR:?}/dev/$prefix*"
 
 	# Send idle message to frozen raids (with hope to unfreeze them)
-	for dm in $(dm_status | egrep "$prefix.*raid.*frozen"); do
+	for dm in $(dm_status | grep -E "$prefix.*raid.*frozen"); do
 		echo "## unfreezing: dmsetup message \"${dm%:*}\""
 		dmsetup message "${dm%:*}" 0 "idle" &
 	done


