From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Jun 2019 09:57:40 -0400
Subject: stable-2.02 - tests: automatically set scan_lvs when using extend_filter
Message-ID: <201906051357.x55DveX9028623@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1308572a8754f1f5f614218dc08d15f1b562fb0d
Commit:        1308572a8754f1f5f614218dc08d15f1b562fb0d
Parent:        adf9bf80a32500b45b37eb24b98fa7c2c933019e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 15:45:30 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 5 15:54:59 2019 +0200

tests: automatically set scan_lvs when using extend_filter

When using 'aux extend_filter' we always want to use LV as PV.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bd42f30..3a66f53 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1171,7 +1171,7 @@ extend_filter() {
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
 	done
-	lvmconf "$filter"
+	lvmconf "$filter" "devices/scan_lvs = 1"
 }
 
 extend_filter_LVMTEST() {


