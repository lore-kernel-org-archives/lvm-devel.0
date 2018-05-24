From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:56 -0400
Subject: master - tests: passthrough args with extend_filter_LVMTEST
Message-ID: <201805240934.w4O9YuQF002269@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f865e1bf87b474a0795e5b38456ebbeef406351c
Commit:        f865e1bf87b474a0795e5b38456ebbeef406351c
Parent:        89f34eaf0cc2d3916f9aa640e3a660c6c18fd3b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 11:12:17 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 11:22:59 2018 +0200

tests: passthrough args with extend_filter_LVMTEST

Don't rebuild config twice.
---
 test/lib/aux.sh                 |    2 +-
 test/shell/lvmetad-pvscan-md.sh |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bf766f2..b47ce1f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1175,7 +1175,7 @@ extend_filter() {
 }
 
 extend_filter_LVMTEST() {
-	extend_filter "a|$DM_DEV_DIR/$PREFIX|"
+	extend_filter "a|$DM_DEV_DIR/$PREFIX|" "$@"
 }
 
 hide_dev() {
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index 4d4dae2..5fb4d50 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -25,8 +25,7 @@ aux prepare_devs 2
 aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
 
 aux lvmconf 'devices/md_component_detection = 1'
-aux extend_filter_LVMTEST
-aux extend_filter "a|/dev/md.*|"
+aux extend_filter_LVMTEST "a|/dev/md|"
 
 pvdev=$(< MD_DEV_PV)
 


