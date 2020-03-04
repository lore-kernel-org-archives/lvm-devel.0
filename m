From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:52 -0500
Subject: master - tests: pvck dump from larger metadata areas
Message-ID: <202003041458.024Ewqgu015659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6667f94cb1204aad5703d129aeeca8286ebaf18
Commit:        f6667f94cb1204aad5703d129aeeca8286ebaf18
Parent:        1b711b955db17617e723abcfcb0b8e21eb0ce7f5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 3 13:44:59 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

tests: pvck dump from larger metadata areas

---
 test/shell/pvck-dump.sh | 35 ++++++++++++++++++++++++++++++++++-
 1 file changed, 34 insertions(+), 1 deletion(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 17faa17..5c662f6 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -12,7 +12,7 @@
 
 . lib/inittest
 
-aux prepare_devs 4
+aux prepare_devs 8 512
 get_devs
 
 dd if=/dev/zero of="$dev1" || true
@@ -129,3 +129,36 @@ diff area1 area3b
 
 vgremove -ff $vg
 
+pvremove "$dev1"
+pvremove "$dev2"
+pvremove "$dev3"
+pvremove "$dev4"
+
+pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
+
+vgcreate $SHARED -s 512K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8"
+
+for i in `seq 1 500`; do lvcreate -an -n lv$i -l1 $vg; done
+
+pvck --dump headers "$dev1" > h1
+
+pvck --dump metadata_search "$dev1" > m1
+grep "seqno 500" m1
+
+dd if="$dev1" of=dev1dd bs=1M count=32
+dd if=/dev/zero of="$dev1" bs=4K count=1
+
+# mda_size for mda1 is 32M - 4K
+pvck --dump metadata_search --settings "mda_num=1 mda_size=33550336" "$dev1" > m1b
+grep "seqno 500" m1b
+
+pvck --dump metadata_search --settings "mda_num=1 mda_size=33550336" dev1dd > m1c
+grep "seqno 500" m1c
+
+# mda_size for mda2 is 32M
+pvck --dump metadata_search --settings "mda_num=2 mda_size=33554432" "$dev1" > m2
+grep "seqno 500" m2
+
+dd if=dev1dd of="$dev1" bs=1M count=32
+
+vgremove -ff $vg



