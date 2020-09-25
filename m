From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:11 +0000 (GMT)
Subject: master - tests: also add thick snap of thin volume
Message-ID: <20200925210711.C28B3385782E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a89ac3bf6f84be5a021691d02bad3ac5e315da78
Commit:        a89ac3bf6f84be5a021691d02bad3ac5e315da78
Parent:        ccb58c109ffab7a073e1630e48babf5eae052ee8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 20:49:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

tests: also add thick snap of thin volume

---
 test/shell/vgsplit-thin.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index a2d0a0b7f..abe9f552f 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -27,6 +27,7 @@ get_devs
 vgcreate "$vg1" "${DEVICES[@]}"
 lvcreate -T -L8M $vg1/pool1 -V10M -n $lv1 "$dev1" "$dev2"
 lvcreate -T -L8M $vg1/pool2 -V10M -n $lv2 "$dev3" "$dev4"
+lvcreate -s -L2M -n snap $vg1/$lv1 "$dev2"
 
 # Test with external origin if available
 lvcreate -l1 -an -pr --zero n -n eorigin $vg1 "$dev5"


