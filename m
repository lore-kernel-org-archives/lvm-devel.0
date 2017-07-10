From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:21 -0400
Subject: master - tests: utils.sh assign directly
Message-ID: <201707101233.v6ACXLWd022797@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d12c0ae16315680efcd2306f8f657d45e7c4aca6
Commit:        d12c0ae16315680efcd2306f8f657d45e7c4aca6
Parent:        f21d81212797c56ed49b6371adc88316e436ca69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 9 13:38:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: utils.sh assign directly

Assign properly quoted vars in eval directly.
---
 test/lib/utils.sh |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index f4c52ad..4e43e64 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -246,12 +246,10 @@ prepare_test_vars() {
 	vg="${PREFIX}vg"
 	lv=LV
 
-	for i in $(seq 1 16); do
-		name="${PREFIX}pv$i"
-		dev="$DM_DEV_DIR/mapper/$name"
-		eval "dev$i=\"$dev\""
-		eval "lv$i=LV$i"
-		eval "vg$i=${PREFIX}vg$i"
+	for i in {1..16}; do
+		eval "dev$i=\"$DM_DEV_DIR/mapper/${PREFIX}pv$i\""
+		eval "lv$i=\"LV$i\""
+		eval "vg$i=\"${PREFIX}vg$i\""
 	done
 }
 


