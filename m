From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:52 +0000 (GMT)
Subject: master - tests: support for 16T is needed
Message-ID: <20200912112452.6DE2F3892454@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3008e1be08c92fc9ee409397c174805d4193e63b
Commit:        3008e1be08c92fc9ee409397c174805d4193e63b
Parent:        17dbb24f7c9715b33a3b35cfa06c1c25657fddd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 09:47:38 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

tests: support for 16T is needed

Likely 32bit machines can't pass here.
---
 test/shell/lvcreate-thin-limits.sh | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvcreate-thin-limits.sh b/test/shell/lvcreate-thin-limits.sh
index 101132b9c..6a9c33d82 100644
--- a/test/shell/lvcreate-thin-limits.sh
+++ b/test/shell/lvcreate-thin-limits.sh
@@ -18,6 +18,9 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
 #
 # Main
 #
@@ -29,7 +32,7 @@ get_devs
 
 vgcreate $SHARED -s 4K "$vg" "${DEVICES[@]}"
 
-not lvcreate -T -L15.995T -vvvv --poolmetadatasize 5G $vg/pool
+not lvcreate -T -L15.995T --poolmetadatasize 5G $vg/pool
 
 lvs -ao+seg_pe_ranges $vg
 


