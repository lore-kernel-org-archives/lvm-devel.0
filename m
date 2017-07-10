From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:21 -0400
Subject: master - tests: get.sh use simplier tr
Message-ID: <201707101233.v6ACXLu7022802@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f21d81212797c56ed49b6371adc88316e436ca69
Commit:        f21d81212797c56ed49b6371adc88316e436ca69
Parent:        d426d7e7099b23d169e396292a25ab97cbfc2000
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 11:56:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: get.sh use simplier tr

---
 test/lib/get.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 88144c1..e7139dc 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -68,7 +68,7 @@ lv_devices() {
 }
 
 lv_field_lv_() {
-	lv_field "$1" "$2" -a --unbuffered | sed 's/\[//; s/]//'
+	lv_field "$1" "$2" -a --unbuffered | tr -d []
 }
 
 lv_tree_devices_() {


