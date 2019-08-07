From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 7 Aug 2019 09:29:35 -0400
Subject: stable-2.02 - dev
Message-ID: <201908071329.x77DTZ2G018684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2debf88bf811cd6988ee2aaa1a6925543ab4a92
Commit:        d2debf88bf811cd6988ee2aaa1a6925543ab4a92
Parent:        4a3e1ac7407dff9e53c5efea179a5620ad13f8f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 7 15:22:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 7 15:28:57 2019 +0200

dev

---
 test/shell/lvmetad-disabled.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 84d7b54..7070e1c 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -60,7 +60,10 @@ not grep "WARNING: Not using lvmetad" out
 # because we know one side effect is to disable lvmetad.
 # FIXME: we should install lvmetactl so that we can
 # use that to directly disable lvmetad for tests like this.
-not lvconvert --repair $vg1/$lv1 2>&1 | tee out
+lvs -a $vg1
+#lvcreate -l1 -m1 --alloc anywhere -n $lv2 $vg1
+lvcreate -an -T -l1 $vg1/$lv2
+not lvconvert --repair $vg1/$lv2 2>&1 | tee out
 grep "WARNING: Disabling lvmetad cache" out
 
 pvs  -vvvv 2>&1 | tee out


