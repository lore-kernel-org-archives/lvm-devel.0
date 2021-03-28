From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 28 Mar 2021 12:23:11 +0000 (GMT)
Subject: main - tests: fix unfinished check for 4.18 kernel
Message-ID: <20210328122311.296453858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afbaab20c72515231740a1a6827d0110c6ff59cf
Commit:        afbaab20c72515231740a1a6827d0110c6ff59cf
Parent:        f584f0cd9e84c33128200897eebd6edb22557167
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 28 00:16:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 28 00:21:38 2021 +0100

tests: fix unfinished check for 4.18 kernel

---
 test/shell/thin-flags.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 0b3148a9c..795d47ae5 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -99,9 +99,9 @@ lvs -ao+seg_pe_ranges $vg
 
 # needs_check needs newer version
 THINMINVER="1 20 0"
-aux kernel_at_least 4.18 && THINMINVER="1 19 0" # kernel >=4.18 already had changes from 1.20
+aux kernel_at_least 4 18 && THINMINVER="1 19 0" # kernel >=4.18 already had changes from 1.20
 
-if aux have_thin $THINVER ; then
+if aux have_thin $THINMINVER ; then
 	check lv_attr_bit state $vg/pool "a"
 
 	dmsetup suspend $vg-pool-tpool


