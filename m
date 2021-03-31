From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:43 +0000 (GMT)
Subject: dev-next - tests: ensure raid is synchronized
Message-ID: <20210331214943.112433858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f584f0cd9e84c33128200897eebd6edb22557167
Commit:        f584f0cd9e84c33128200897eebd6edb22557167
Parent:        5ec7992e29fdf3273673f712d6a9f231903b6bf2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 23:15:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:19:08 2021 +0100

tests: ensure raid is synchronized

---
 test/shell/lvconvert-raid-allocation.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index acdae0caa..5420d584d 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -52,6 +52,8 @@ aux wait_for_sync $vg $lv1
 not lvconvert -m +1 $vg/$lv1 \
     "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
 lvconvert -y -m +1 $vg/$lv1 "$dev5"
+aux wait_for_sync $vg $lv1
+# Cannot pass without --yes
 not lvconvert -m 0 $vg/$lv1
 lvconvert -y -m 0 $vg/$lv1
 # Should work due to '--alloc anywhere'


