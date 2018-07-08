From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:26:24 -0400
Subject: master - tests: check how thin-pool allocation works
Message-ID: <201807082226.w68MQOQW016002@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=333eb8667e73439c71dc351a02612c1c7601e8ec
Commit:        333eb8667e73439c71dc351a02612c1c7601e8ec
Parent:        6d1c983122bc2a17bbfbac234f9a73ee9c27f161
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 8 23:24:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:23:35 2018 +0200

tests: check how thin-pool allocation works

Check allocation of thin-pool works on 2PVs, when one is so full,
that even metadata do not fit there (as they need at least 2M,
while 99% of 63MB fills >62MB)
---
 test/shell/lvcreate-thin.sh |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 8e04c9e..9ca7f11 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -199,6 +199,17 @@ check vg_field $vg lv_count 6
 lvremove -ff $vg
 check vg_field $vg lv_count 0
 
+
+# Check how allocator works with 2PVs where one is nearly full
+lvcreate -l99%PV $vg "$dev1"
+lvs -a $vg
+# Check when separate metadata is required, allocation needs to fail
+fail lvcreate -L10 -T --poolmetadataspare n --config 'allocation/thin_pool_metadata_require_separate_pvs=1' $vg
+# Check when data and metadata may share the same PV, it shall pass
+lvcreate -L10 -T --poolmetadataspare n --config 'allocation/thin_pool_metadata_require_separate_pvs=0' $vg
+lvremove -f $vg
+
+
 # Fail cases
 # Too small pool size (1 extent 64KB) for given chunk size
 not lvcreate --chunksize 256 -l1 -T $vg/pool1


