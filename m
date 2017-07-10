From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:02 -0400
Subject: master - tests: check result directly
Message-ID: <201707101228.v6ACS2vw021726@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e68d986cd5374edc5b6884fc1c3dcc197c954b46
Commit:        e68d986cd5374edc5b6884fc1c3dcc197c954b46
Parent:        160cb1e713d1b48f579c26d393e83ee0fd0e6e7d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 10:00:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: check result directly

---
 test/shell/lvconvert-raid-reshape.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 740f4ba..4f4f7c2 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -59,8 +59,8 @@ function _lvconvert
 	[ "${level:0:7}" = "striped" ] && wait_and_check=0
 	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
 
-	lvconvert -y --ty $req_level $R $vg/$lv
-	[ $? -ne 0 ] && return $?
+	lvconvert -y --ty $req_level $R $vg/$lv || return $?
+
 	check lv_first_seg_field $vg/$lv segtype "$level"
 	check lv_first_seg_field $vg/$lv data_stripes $data_stripes
 	check lv_first_seg_field $vg/$lv stripes $stripes


