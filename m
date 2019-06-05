From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Jun 2019 09:49:29 -0400
Subject: master - tests: automatically set scan_lvs when using extend_filter
Message-ID: <201906051349.x55DnTx3026267@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddd68fbeadb42d5cc0fdae49e133524bab049f49
Commit:        ddd68fbeadb42d5cc0fdae49e133524bab049f49
Parent:        e3c4ab0cc788b0190ab58446189c2d6b07a27b98
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 15:45:30 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 5 15:48:44 2019 +0200

tests: automatically set scan_lvs when using extend_filter

When using 'aux extend_filter' we always want to use LV as PV.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1e8f0de..b178ab7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1090,7 +1090,7 @@ extend_filter() {
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
 	done
-	lvmconf "$filter"
+	lvmconf "$filter" "devices/scan_lvs = 1"
 }
 
 extend_filter_LVMTEST() {


