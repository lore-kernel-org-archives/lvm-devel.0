From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 15:39:17 +0000 (GMT)
Subject: master - tests: use zero backend
Message-ID: <20200919153917.30EFF386191C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f63aac5309e10335c3a53477b3838fe1821934e1
Commit:        f63aac5309e10335c3a53477b3838fe1821934e1
Parent:        f7c58c636debe351ddd97371c8d32c3f79cdbf79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 15:58:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 17:30:51 2020 +0200

tests: use zero backend

Since we are not reading read - just use zero device as backend for
test, so we do not eat real disk space.
---
 test/shell/lvcreate-large-raid.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index b66cfd26e..a7af9cb48 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -38,7 +38,7 @@ aux lvmconf 'devices/issue_discards = 1'
 # Delay PVs so that resynchronization doesn't fill too much space
 for device in "${DEVICES[@]}"
 do
-	aux delay_dev "$device" 0 10  "$(get first_extent_sector "$device")"
+	aux zero_dev "$device" "$(( $(get first_extent_sector "$device") + 8192 )):"
 done
 
 # bz837927 START


