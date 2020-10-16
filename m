From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:13 +0000 (GMT)
Subject: stable-2.02 - tests: also add thick snap of thin volume
Message-ID: <20201016191213.CAC7A396EC8A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c380d4e9e27470473c2a29e518bb27f7eec622c6
Commit:        c380d4e9e27470473c2a29e518bb27f7eec622c6
Parent:        e05c882ab5a2ef55ff86fc326f845220c34504b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 24 20:49:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

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


