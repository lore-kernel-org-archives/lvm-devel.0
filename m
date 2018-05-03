From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 09:23:45 -0400
Subject: master - functional tests: Update have_raid function
Message-ID: <201805031323.w43DNjR3013696@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52656c89fd6e7655b0599e20f90cc9d70561f1fb
Commit:        52656c89fd6e7655b0599e20f90cc9d70561f1fb
Parent:        9cab0057971eea27f31c8e3b2a83d69337d0155d
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 14:22:24 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 14:22:24 2018 +0100

functional tests: Update have_raid function

No need to check if it's built in.
---
 test/lib/aux.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e44116f..2984af3 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1492,10 +1492,6 @@ have_thin() {
 }
 
 have_raid() {
-	test "$RAID" = shared -o "$RAID" = internal || {
-		echo "Raid is not built-in." >&2
-		return 1;
-	}
 	target_at_least dm-raid "$@"
 
 	# some kernels have broken mdraid bitmaps, don't use them!


