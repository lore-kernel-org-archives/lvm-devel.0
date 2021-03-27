From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 27 Mar 2021 22:19:41 +0000 (GMT)
Subject: main - tests: for 4.18 use already 1.20 logic
Message-ID: <20210327221941.1D280385801D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37d603268f98ba51d9fd9c734004274de8fcca1b
Commit:        37d603268f98ba51d9fd9c734004274de8fcca1b
Parent:        f07a793813a51bd792f7a5a5e290a6727100aaca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 19:28:43 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:16:52 2021 +0100

tests: for 4.18 use already 1.20 logic

Looks like there was some missed versioning increase during devel.
So with kernel >= 4.18 version 1.19 is enough to look like 1.20

However backported 1.19 targets seems to not provide all
the capabilities.
---
 test/shell/thin-flags.sh | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 6e5749a74..0b3148a9c 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -98,7 +98,10 @@ not lvcreate -V10 -n $lv3 $vg/pool
 lvs -ao+seg_pe_ranges $vg
 
 # needs_check needs newer version
-if aux have_thin 1 20 0 ; then
+THINMINVER="1 20 0"
+aux kernel_at_least 4.18 && THINMINVER="1 19 0" # kernel >=4.18 already had changes from 1.20
+
+if aux have_thin $THINVER ; then
 	check lv_attr_bit state $vg/pool "a"
 
 	dmsetup suspend $vg-pool-tpool


