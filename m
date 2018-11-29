From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:12 -0500
Subject: master - tests: requires at least 2 iterations
Message-ID: <201811292213.wATMDCw7016676@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=217d647a468c3111738e61e02e56b6744b788a2f
Commit:        217d647a468c3111738e61e02e56b6744b788a2f
Parent:        5f87ba68d409dc8da02aa8d9c58798eb5f2d4477
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 23 20:09:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:09 2018 +0100

tests: requires at least 2 iterations

---
 test/shell/metadata-full.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/metadata-full.sh b/test/shell/metadata-full.sh
index 67333d8..a1b7d02 100644
--- a/test/shell/metadata-full.sh
+++ b/test/shell/metadata-full.sh
@@ -79,7 +79,7 @@ for i in $(seq 1 "$TEST_DEVS"); do
 done
 
 # test we hit 'out-of-metadata-space'
-test "$i" -gt 5
+test "$i" -gt 2
 test "$i" -lt "$TEST_DEVS"
 
 # should show 0


