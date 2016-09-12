From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:55 +0000 (UTC)
Subject: master - tests: slow down disks more
Message-ID: <20160912145255.0D4C660F3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ddcbe22b7f8004346a3b08ad09954f319baab2a
Commit:        4ddcbe22b7f8004346a3b08ad09954f319baab2a
Parent:        5b55f9616df036078a2cfbfc6b7a19a1f31d7f22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 12 16:48:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:51:53 2016 +0200

tests: slow down disks more

---
 test/shell/lvchange-rebuild-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index e4c579e..6cc500d 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -21,7 +21,7 @@ aux prepare_vg 8
 # Delay 1st leg so that rebuilding status characters can be read
 for d in $(< DEVICES)
 do
-	aux delay_dev "$d" 0 10 $(get first_extent_sector "$d")
+	aux delay_dev "$d" 0 15 $(get first_extent_sector "$d")
 done
 
 # rhbz 1064592


