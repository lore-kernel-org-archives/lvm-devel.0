From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:36 +0000 (GMT)
Subject: main - tests: lvdisplay does not crash for merged thin
Message-ID: <20210217105436.BCC6D382E818@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ef0861355ad70589959d1e92b53f91424197946
Commit:        3ef0861355ad70589959d1e92b53f91424197946
Parent:        14008ead2a42b4a5db0c81e444f9ea1a05c1a899
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 13 23:10:15 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

tests: lvdisplay does not crash for merged thin

---
 test/shell/thin-merge.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index c0a022c57..34f5c7428 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -64,6 +64,9 @@ grep "Merging of thin snapshot $vg/snap will occur on next activation of $vg/${l
 not lvconvert --merge $vg/snap1 &>out
 grep "Cannot merge snapshot" out
 
+# Check lvdisplay is not crashing while merge needs to wait
+lvdisplay -a $vg
+
 umount mnt
 
 # Merge cannot happen


