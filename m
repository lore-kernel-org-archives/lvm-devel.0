From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 12:10:02 -0500
Subject: master - tests: update required raid target
Message-ID: <201811191710.wAJHA25M030158@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1e9fe9505293e8c9b4a4bfffafe62c5a83b4d11
Commit:        b1e9fe9505293e8c9b4a4bfffafe62c5a83b4d11
Parent:        cb15373ad705a360c4a32d4ca9e97af949fec17a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 18:06:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 18:08:54 2018 +0100

tests: update required raid target

For embeded reshaping operation require higher driver version.
(otherwise we get:

Converting vg/LV1 from raid6 (same as raid6_zr) is directly possible to the following layouts:
 raid6_nc
 raid6_nr
 raid6_la_6
 raid6_ls_6
 raid6_ra_6
 raid6_rs_6
 raid6_n_6
---
 test/shell/lvconvert-raid-regionsize.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index cba04cc..924e95a 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -65,7 +65,8 @@ _test_regionsizes raid1
 # Clean up
 lvremove --yes $vg
 
-if aux have_raid 1 10 1; then
+# Needs reshaping kernel for raid6 conversion
+if aux have_raid 1 14 0; then
 # Create 5-way raid6
 lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid6"


