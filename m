From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Mar 2016 10:18:57 +0000 (UTC)
Subject: master - tests: update vg-check-devs-used.sh
Message-ID: <20160322101857.8C71E60F2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d26d283ea7234ee3e4499b53f185696e0c5e15c
Commit:        3d26d283ea7234ee3e4499b53f185696e0c5e15c
Parent:        6a915270fc7837d18c2e6daf55d75c3763bc2866
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 22 11:18:16 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 22 11:18:22 2016 +0100

tests: update vg-check-devs-used.sh

Snapshot needs to be activated exclusively in cluster...
---
 test/shell/vg-check-devs-used.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 09109e5..c978b9e 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -26,8 +26,8 @@ lvremove -ff $vg
 
 # Also test if sub LVs with suffixes are correctly processed.
 # Check with thick snapshot which has sub LVs with -real and -cow suffix in UUID.
-lvcreate -l1 -n $lv $vg
-lvcreate -l1 -s $vg/$lv
+lvcreate -l1 -aey -n $lv $vg
+lvcreate -l1 -aey -s $vg/$lv
 pvs 2>err
 not grep "WARNING: Device mismatch detected for $vg/$lv" err
 


