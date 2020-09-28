From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Sep 2020 18:29:30 +0000 (GMT)
Subject: master - tests: add case for metadata checksum differences
Message-ID: <20200928182930.D5D52386101B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb96e9ab217641ec3a967d9aa2be01fc936ee038
Commit:        fb96e9ab217641ec3a967d9aa2be01fc936ee038
Parent:        df6f16c081ffca48f2c812e539851995b7563b68
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 28 13:21:44 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 28 13:25:57 2020 -0500

tests: add case for metadata checksum differences

Cover the case where two copies of metadata have the
same seqno but different checksums.  Also elaborate
on an existing fixme in the code for this case, since
we should be doing something better for this case.

This had been uncovering an issue with reopening
fds in readwrite mode.
---
 lib/cache/lvmcache.c       |  3 +++
 test/shell/metadata-old.sh | 45 +++++++++++++++++++++++++++++++++++++++++++++
 test/shell/pvck-repair.sh  |  2 --
 3 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d8df4c796..9716eccaf 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1663,6 +1663,9 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
 		 * second updated to seqno 4, first comes back and second goes
 		 * missing, first updated to seqno 4, second comes back, now
 		 * both are present with same seqno but different checksums.
+		 * FIXME: we should check if the majority of mda copies have one
+		 * checksum and if so use that copy of metadata, but if there's
+		 * not a majority, don't allow the VG to be modified/activated.
 		 */
 
 		if ((vginfo->mda_size != vgsummary->mda_size) || (vginfo->mda_checksum != vgsummary->mda_checksum)) {
diff --git a/test/shell/metadata-old.sh b/test/shell/metadata-old.sh
index 53133bc6a..a193ebf31 100644
--- a/test/shell/metadata-old.sh
+++ b/test/shell/metadata-old.sh
@@ -175,3 +175,48 @@ lvs $vg/$lv4
 
 vgchange -an $vg
 vgremove -ff $vg
+
+# Test when the metadata on two PVs have the same seqno
+# but different checksums.
+
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+
+pvcreate "$dev1"
+pvcreate "$dev2"
+
+vgcreate $SHARED $vg "$dev1" "$dev2"
+
+lvcreate -n $lv1 -l1 -an $vg
+
+pvck --dump metadata -f meta "$dev2"
+
+# change an unimportant character so the metadata is effectively
+# the same in content but will have a different checksum
+sed 's/Linux/linux/' meta > meta2
+
+# write out the changed metadata
+pvck --repair -y -f meta2 "$dev2"
+
+# the vg can still be used but will produce warnings
+# the mda on one pv is updated, but not the other,
+# which changes the error from a checksum inconsistency
+# into a seqno inconsistency.
+lvs $vg 2>&1 | tee out
+grep WARNING out
+grep $lv1 out
+lvcreate -n $lv2 -l1 -an $vg 2>&1 |tee out
+grep WARNING out
+lvs $vg 2>&1 | tee out
+grep WARNING out
+grep $lv1 out
+grep $lv2 out
+
+# correct the senqo inconsistency
+vgck --updatemetadata $vg
+lvs $vg 2>&1 | tee out
+not grep WARNING out
+grep $lv1 out
+grep $lv2 out
+
+vgremove -ff $vg
diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
index b6038944a..d48e25198 100644
--- a/test/shell/pvck-repair.sh
+++ b/test/shell/pvck-repair.sh
@@ -399,8 +399,6 @@ lvcreate -l1 -an $vg
 # One PV, one mda, pv_header zeroed, unmatching dev name requires specified uuid
 _clear_devs "$dev1" "$dev2"
 vgcreate $vg "$dev1"
-#!!! FIXME: with this hits INTERNAL_ERROR
-#!!! vgcreate $vg "$dev1" "$dev2"
 pvck --dump headers "$dev1" || true
 UUID1=`pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}'`
 echo $UUID1


