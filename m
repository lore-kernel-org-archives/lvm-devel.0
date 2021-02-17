From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:48 +0000 (GMT)
Subject: main - tests: readonly snapshot thick origin can't be merged
Message-ID: <20210217105448.228233854819@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9846bdc3e420348646d26259ad57c60b6f2ebf9
Commit:        b9846bdc3e420348646d26259ad57c60b6f2ebf9
Parent:        868b733588ff5629e1318bf3efcfbceb2ac8db8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:38:28 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

tests: readonly snapshot thick origin can't be merged

When user sets snapshot thick origin as read-only - lvconvert --merge refuses
to merge until user swiches origin to 'read-write'.
---
 test/shell/snapshot-merge.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index a50ffdcd8..ff9de96f8 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -55,6 +55,12 @@ setup_merge_ $vg $lv1
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge
 
+# check read-only origin is protected from being merge
+lvchange -pr $vg/$lv1
+not lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")" |& tee out
+grep "read-only origin" out
+lvchange -prw $vg/$lv1
+
 # check exclusive lock is preserved after merge
 check lv_field "$vg/$lv1" lv_active_exclusively "active exclusively"
 lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"


