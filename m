From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 13 Jan 2021 13:18:30 +0000 (GMT)
Subject: main - tests: check thin-pool corner case allocs
Message-ID: <20210113131830.29FA1387084C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71162b2b4e09c08f08457d923dcc552251bd3c83
Commit:        71162b2b4e09c08f08457d923dcc552251bd3c83
Parent:        0b6ee6a9121c688af491692cab65bd6f17cf49d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 12 23:26:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 13 12:54:45 2021 +0100

tests: check thin-pool corner case allocs

---
 test/shell/lvcreate-thin-limits.sh | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-thin-limits.sh b/test/shell/lvcreate-thin-limits.sh
index 6a9c33d82..5dcc160dc 100644
--- a/test/shell/lvcreate-thin-limits.sh
+++ b/test/shell/lvcreate-thin-limits.sh
@@ -27,13 +27,35 @@ aux can_use_16T || skip
 aux have_thin 1 0 0 || skip
 which mkfs.ext4 || skip
 
-aux prepare_pvs 1 16777216
+# 16T device
+aux prepare_pvs 2 8388608
 get_devs
 
-vgcreate $SHARED -s 4K "$vg" "${DEVICES[@]}"
+# gives 16777215M device
+vgcreate $SHARED -s 4M "$vg" "${DEVICES[@]}"
 
-not lvcreate -T -L15.995T --poolmetadatasize 5G $vg/pool
+# For 1st. pass only single PV
+lvcreate -l100%PV --name $lv1 $vg "$dev2"
 
-lvs -ao+seg_pe_ranges $vg
+for i in 1 0
+do
+	SIZE=$(get vg_field "$vg" vg_free --units m)
+	SIZE=${SIZE%%\.*}
+
+	# ~16T - 2 * 5G + something  -> should not fit
+	not lvcreate -Zn -T -L$(( SIZE - 2 * 5 * 1024 + 1 )) --poolmetadatasize 5G $vg/pool
+
+	check vg_field "$vg" lv_count "$i"
+
+	# Should fit  data + metadata + pmspare
+	lvcreate -Zn -T -L$(( SIZE - 2 * 5 * 1024 )) --poolmetadatasize 5G $vg/pool
+
+	check vg_field "$vg" vg_free "0"
+
+	lvs -ao+seg_pe_ranges $vg
+
+        # Remove everything for 2nd. pass
+	lvremove -ff $vg
+done
 
 vgremove -ff $vg


