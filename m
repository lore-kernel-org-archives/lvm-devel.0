From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:16 +0000 (GMT)
Subject: stable-2.02 - tests: lvdisplay does not crash for merged thin
Message-ID: <20210217120116.3EF3A389850A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f6c287aaca04aa1a791c341cbff7b6cbff9a29b
Commit:        1f6c287aaca04aa1a791c341cbff7b6cbff9a29b
Parent:        7243e32ce56c2f33fb7cfd735dc6abf27f868c00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 13 23:10:15 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:56:13 2021 +0100

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


