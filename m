From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 15:13:05 -0400
Subject: master - tests: bound variables
Message-ID: <201707131913.v6DJD5xt013588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=870c7bc76c291aec4c475436f13328fdc0467881
Commit:        870c7bc76c291aec4c475436f13328fdc0467881
Parent:        e88534b680f52a98e72b43f5b6c1d65f158e5680
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 13 21:09:45 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 13 21:11:16 2017 +0200

tests: bound variables

---
 test/shell/lvconvert-raid-takeover.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 2fb0e5a..c8591be 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -26,7 +26,7 @@ aux prepare_vg 8
 # FIXME: lvconvert leaks  'error' devices
 detect_error_leak_()
 {
-	local err
+	local err=""
 
 	for i in $(dmsetup info -c -o name --noheadings) ; do
 		case "$i" in
@@ -66,7 +66,7 @@ function _lvconvert
 	local stripes=$4
 	local vg=$5
 	local lv=$6
-	local region_size=$7
+	local region_size=${7-}
 	local wait_and_check=1
 	local R=""
 


