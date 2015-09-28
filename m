From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 28 Sep 2015 11:26:14 +0000 (UTC)
Subject: master - test: Cope with stripe rounding message change.
Message-ID: <20150928112614.34CC260A6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7097663dddad0716059783219e9e3d4748db8188
Commit:        7097663dddad0716059783219e9e3d4748db8188
Parent:        eab099b22190cfaf68f013e785dd13c43277fea1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 28 12:25:31 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 28 12:25:31 2015 +0100

test: Cope with stripe rounding message change.

---
 test/shell/lvcreate-striped-mirror.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index 735b396..776dbf7 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -46,12 +46,12 @@ check mirror_images_redundant $vg $lv7
 lvremove -ff $vg
 
 lvcreate -aey --nosync -i3 -l4 --type mirror -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
-grep "Rounding size (4 extents) up to .* (6 extents)" log
+grep "Rounding size .*(4 extents) up to .*(6 extents)" log
 
 lvcreate -aey --nosync -i3 -l4 --type mirror -m2 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
-grep "Rounding size (4 extents) up to .* (6 extents)" log
+grep "Rounding size .*(4 extents) up to .*(6 extents)" log
 
 lvcreate -aey --nosync -i3 -l2 --type mirror -m2 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
-grep "Rounding size (2 extents) up to .* (3 extents)" log
+grep "Rounding size .*(2 extents) up to .*(3 extents)" log
 
 lvremove -ff $vg


