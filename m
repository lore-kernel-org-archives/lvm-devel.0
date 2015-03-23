From: okozina <okozina@fedoraproject.org>
Date: Mon, 23 Mar 2015 13:58:11 +0000 (UTC)
Subject: master - tests: add omitted --atomic mode in pvmove-restart
Message-ID: <20150323135811.8B4F660BAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=192a83def3095b33b5590d0531d24a26588b4aef
Commit:        192a83def3095b33b5590d0531d24a26588b4aef
Parent:        6e7b24d34ff3da1c56718bb7def8a8ecd4258c43
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Mar 23 14:55:13 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 23 14:55:13 2015 +0100

tests: add omitted --atomic mode in pvmove-restart

---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 398095b..022e7c8 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -31,7 +31,7 @@ lvextend -l+10 $vg/$lv1 "$dev2"
 # Slowdown writes
 aux delay_dev "$dev3" 0 100
 
-pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" &
+pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
 while not dmsetup status "$vg-pvmove0"; do sleep .1; done


