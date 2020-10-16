From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:44 +0000 (GMT)
Subject: stable-2.02 - tests: use zero backend
Message-ID: <20201016191144.0AC21396EC8E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=688c72411e206008d5cd7553ed0b126549b7f987
Commit:        688c72411e206008d5cd7553ed0b126549b7f987
Parent:        cd681efd9fa2d2fd74093e702c708461dc5f0348
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 15:58:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

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


