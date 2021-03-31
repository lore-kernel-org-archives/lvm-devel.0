From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:36 +0000 (GMT)
Subject: dev-next - tests: correct thin-pool version
Message-ID: <20210331214936.2D3843858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f07a793813a51bd792f7a5a5e290a6727100aaca
Commit:        f07a793813a51bd792f7a5a5e290a6727100aaca
Parent:        53338cf566838381febe37d8254275e5f2a408ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 00:33:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 00:34:00 2021 +0100

tests: correct thin-pool version

Use thin-pool target version 1.20 for changed behavior.
---
 test/shell/thin-flags.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 89ed69ac9..6e5749a74 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -98,7 +98,7 @@ not lvcreate -V10 -n $lv3 $vg/pool
 lvs -ao+seg_pe_ranges $vg
 
 # needs_check needs newer version
-if aux have_thin 1 19 0 ; then
+if aux have_thin 1 20 0 ; then
 	check lv_attr_bit state $vg/pool "a"
 
 	dmsetup suspend $vg-pool-tpool


