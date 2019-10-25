From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:36 -0400
Subject: stable-2.02 - tests: really check disabling of lvmetad
Message-ID: <201910252255.x9PMtaEk011992@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc200e0b16676398eb0e2244ffa14315d25a1a5a
Commit:        bc200e0b16676398eb0e2244ffa14315d25a1a5a
Parent:        36b8b9ed5c4b96d3a6482d76ca3eae54c62f9f2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 24 16:43:06 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:29:44 2019 +0200

tests: really check disabling of lvmetad

Since lvconvert validated LV types that can be repaired,
the test was not working properly for longer time...
---
 test/shell/lvmetad-disabled.sh |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 84d7b54..389d191 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -55,13 +55,14 @@ grep "$dev1" out
 grep "$dev2" out
 not grep "WARNING: Not using lvmetad" out
 
-# We don't care about the repair, and we know it's
-# not valid on this lv.  We are just running repair
-# because we know one side effect is to disable lvmetad.
-# FIXME: we should install lvmetactl so that we can
-# use that to directly disable lvmetad for tests like this.
-not lvconvert --repair $vg1/$lv1 2>&1 | tee out
+if aux have_raid 1 7 0 ; then
+# lvconvert validates repairable volumes.
+# We want to excercise if disabling of lvmetad works when it's running.
+# For this we create 'raid1' array and run repair on it.
+lvcreate --type raid1 -m1 --nosync -l1 --alloc anywhere -n $lv2 $vg1
+lvconvert -y --repair $vg1/$lv2 2>&1 | tee out
 grep "WARNING: Disabling lvmetad cache" out
+fi
 
 pvs  -vvvv 2>&1 | tee out
 grep "$dev1" out


