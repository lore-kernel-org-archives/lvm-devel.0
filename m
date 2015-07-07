From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Jul 2015 07:57:52 +0000 (UTC)
Subject: master - tests: use old snapshot for huge volumes
Message-ID: <20150707075752.B07AA60032@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfd0689d6413437c6d3fb8a8461a22ff0f1b5dc9
Commit:        bfd0689d6413437c6d3fb8a8461a22ff0f1b5dc9
Parent:        0ac20a8fdb971c542790b8f50b32ee071b69f130
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 4 11:41:04 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 7 09:57:32 2015 +0200

tests: use old snapshot for huge volumes

Avoid stacking thins over thins.
---
 test/shell/lvconvert-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 8270c0e..b4b3a72 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -36,7 +36,7 @@ vgcreate $vg1 $(head -n 3 DEVICES)
 # maybe  uname -m    [ x86_64 | i686 ]
 TSIZE=64T
 aux can_use_16T || TSIZE=15T
-lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
+lvcreate --type snapshot -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"


