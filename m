From: okozina <okozina@fedoraproject.org>
Date: Thu, 29 Oct 2015 12:32:21 +0000 (UTC)
Subject: master - tests: replace invalid use of 'fail' with 'die'
Message-ID: <20151029123221.198206020C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bca55c9b205ff2b0613ad44d85c12c6d6ae9691b
Commit:        bca55c9b205ff2b0613ad44d85c12c6d6ae9691b
Parent:        f104a81932e1011acb4798402f4f67f78f701a0b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Oct 29 13:30:29 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Thu Oct 29 13:30:29 2015 +0100

tests: replace invalid use of 'fail' with 'die'

---
 test/shell/lvconvert-mirror.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 029112c..5c7aad3 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -317,7 +317,7 @@ lvremove -ff $vg
 # to get synced
 lvcreate -l2 -n $lv1 $vg
 lvconvert --type mirror -i1 -m1 $vg/$lv1 | tee out
-grep -e "$vg/$lv1: Converted:" out || fail "Missing sync info in foreground mode"
+grep -e "$vg/$lv1: Converted:" out || die "Missing sync info in foreground mode"
 lvremove -ff $vg
 
 vgremove -ff $vg


