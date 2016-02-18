From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 17:12:03 +0000 (UTC)
Subject: master - tests: needs_check needs version 16
Message-ID: <20160218171203.CC1CF60ED8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a89ddda1a292402a2cf2422d09e58dba46079163
Commit:        a89ddda1a292402a2cf2422d09e58dba46079163
Parent:        42b394c1425c18fb236e82847c64258afd150ae6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 18:10:31 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 18:11:29 2016 +0100

tests: needs_check needs version 16

Skip part of test when driver is too old.
---
 test/shell/thin-flags.sh |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 336e541..7dd0d6e 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -92,23 +92,26 @@ lvchange -ay $vg/$lv2
 dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1
 
 check lv_attr_bit health $vg/pool "M"
-check lv_attr_bit state $vg/pool "c"
-check lv_field $vg/pool lv_check_needed "check needed"
 # TODO - use spaces ??
 check lv_field $vg/pool lv_health_status "metadata_read_only"
-
 check lv_attr_bit health $vg/$lv2 "-"
 
-dmsetup suspend $vg-pool-tpool
+# needs_check needs newer version
+if aux have_thin 1 16 0 ; then
+	check lv_attr_bit state $vg/pool "c"
+	check lv_field $vg/pool lv_check_needed "check needed"
+
+	dmsetup suspend $vg-pool-tpool
 
-# suspended  thin-pool with Capital 'c'
-check lv_attr_bit state $vg/pool "C"
+	# suspended  thin-pool with Capital 'c'
+	check lv_attr_bit state $vg/pool "C"
 
-dmsetup resume $vg-pool-tpool
+	dmsetup resume $vg-pool-tpool
 
-lvresize -L+2M $vg/pool_tmeta
+	lvresize -L+2M $vg/pool_tmeta
 
-# still require thin_check
-check lv_attr_bit state $vg/pool "c"
+	# still require thin_check
+	check lv_attr_bit state $vg/pool "c"
+fi
 
 vgremove -ff $vg


