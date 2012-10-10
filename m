From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:23:11 +0000 (UTC)
Subject: master - test: use exclusive activation for created mirrors
Message-ID: <20121010192311.E77FEAB3C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14283662b9a1595e231f31bb7165a18d93d66cc2
Commit:        14283662b9a1595e231f31bb7165a18d93d66cc2
Parent:        9db5217a3111f72298de31a6b94d33fff39401a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 10 18:38:55 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:22:12 2012 +0200

test: use exclusive activation for created mirrors

---
 test/shell/lvconvert-thin.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 29beb93..97ccc09 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -22,8 +22,8 @@ aux prepare_pvs 4 64
 vgcreate $vg -s 64K $(cat DEVICES)
 
 # create mirrored LVs for data and metadata volumes
-lvcreate -l8 -m1 --mirrorlog core -n $lv1 $vg
-lvcreate -l4 -m1 --mirrorlog core -n $lv2 $vg
+lvcreate -aey -l8 -m1 --mirrorlog core -n $lv1 $vg
+lvcreate -aey -l4 -m1 --mirrorlog core -n $lv2 $vg
 
 lvconvert -c 64K --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 


