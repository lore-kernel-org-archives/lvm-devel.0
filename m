From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:02 +0000 (UTC)
Subject: master - tests: slower device
Message-ID: <20161211223502.32E9960C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=198f335139f7a538272c8cb6657ad4f5d58b01db
Commit:        198f335139f7a538272c8cb6657ad4f5d58b01db
Parent:        4a33e4c509fb72bf3540d20bd35e1f0944e1d37a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 15:07:14 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

tests: slower device

Some of test machines are too fast, slow raid syncing even more.
---
 test/shell/lvchange-rebuild-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 6b91941..df6a8cb 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -21,7 +21,7 @@ aux prepare_vg 8
 # Delay legs so that rebuilding status characters can be read
 for d in $(< DEVICES)
 do
-	aux delay_dev "$d" 0 15 $(get first_extent_sector "$d")
+	aux delay_dev "$d" 0 20 $(get first_extent_sector "$d")
 done
 
 # rhbz 1064592


