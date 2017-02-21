From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Feb 2017 00:01:16 +0000 (UTC)
Subject: master - tests: use exclusive activation for mirror
Message-ID: <20170221000116.C96AD60B92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=921d5972e8bfa778f7389c4abdaa8691ce432c70
Commit:        921d5972e8bfa778f7389c4abdaa8691ce432c70
Parent:        86a660be7b31809500488792a93670a703e12a27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 20 23:50:27 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 21 00:52:05 2017 +0100

tests: use exclusive activation for mirror

Test suite does not support clustered mirroring.
---
 test/shell/lvresize-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 35f6e57..30cb8d5 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -42,7 +42,7 @@ not lvreduce -L 32M $vg/lv
 
 lvremove -ff $vg
 
-lvcreate --type mirror -L 4 -n $lv1 $vg
+lvcreate --type mirror -aey -L 4 -n $lv1 $vg
 # Incorrent name for resized LV
 not lvextend --type mirror -L 10 -n $lv1 $vg
 # Same size


