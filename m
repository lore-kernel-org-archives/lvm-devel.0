From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:37 +0000 (UTC)
Subject: master - tests: select-tools.sh: pvchange now uses process_each_pv
Message-ID: <20150213102937.3933C6102A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c005b557a4b4d282d853e2437536f244bbf72b2
Commit:        1c005b557a4b4d282d853e2437536f244bbf72b2
Parent:        969d2bf4484810e1c3d402a45cb433b3bee19191
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 10:52:36 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 11:27:09 2015 +0100

tests: select-tools.sh: pvchange now uses process_each_pv

pvchange now uses process_each_pv so uncomment parts of the test
which check proper functionality of intersection between selection
result and PVs or PV tags directly provided on command line. This
didn't work properly before when pvchange was not using process_each_pv.

For example:

  pvchange -u -S 'pv_name=/dev/sda' /dev/sdb

..changes nothing since clearly the intersection of /dev/sda and
/dev/sdb is empty set. The same applies for tags:

  pvchange -u -S 'pv_name=/dev/sda' @some_tag

..changes nothing if /dev/sda is not tagged with some_tag.
---
 test/shell/select-tools.sh |   63 +++++++++++++++++--------------------------
 1 files changed, 25 insertions(+), 38 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index 1cbbf87..b727fd7 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -196,17 +196,6 @@ lvchange --deltag 210 --deltag tag $vg1 $vg2
 # exercise process_each_pv with selection #
 ###########################################
 
-# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-# WARNING: pvchange doesn't use process_each_pv yet
-#          but add the tests anyway as this transition
-#          will happen soon - all these tests should
-#          just work (for now, there's a workaround done
-#          in pvchange code to work with the selection).
-#          Let's use {vg,lv,pv}change to exercise all this
-#          selection support so the tests remain readable
-#          and consistent.
-# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-
 # select contains VGS field
 pvchange --addtag 301 -S "vg_name=$vg1"
 check pv_field $dev1 pv_tags 301
@@ -250,30 +239,28 @@ pvchange -a --deltag 305
 # intersection between selection
 # result and supplied VG name/tag
 
-# ENABLE TESTS BELOW ONCE process_each_pv is used for pvchange
-
-#pvchange --addtag 306 -S "pv_name=$dev1" $dev2
-#not check pv_field $dev1 pv_tags 306
-#not check pv_field $dev2 pv_tags 306
-#not check pv_field $dev3 pv_tags 306
-#not check pv_field $dev4 pv_tags 306
-#pvchange -a --deltag 306
-#pvchange --addtag 307 -S "pv_name=$dev1" $dev1
-#check pv_field $dev1 pv_tags 307
-#not check pv_field $dev2 pv_tags 307
-#not check pv_field $dev3 pv_tags 307
-#not check pv_field $dev4 pv_tags 307
-#pvchange -a --deltag 307
-#pvchange --addtag "tag" $dev1
-#pvchange --addtag 308 -S "pv_name=$dev2" @tag
-#not check pv_field $dev1 pv_tags "308,tag"
-#not check pv_field $dev2 pv_tags "308,tag"
-#not check pv_field $dev3 pv_tags "308,tag"
-#not check pv_field $dev4 pv_tags "308,tag"
-#pvchange --deltag 308 $dev1
-#pvchange --addtag 309 -S "pv_name=$dev1" @tag
-#check pv_field $dev1 pv_tags "309,tag"
-#not check pv_field $dev2 pv_tags "309,tag"
-#not check pv_field $dev3 pv_tags "309,tag"
-#not check pv_field $dev4 pv_tags "309,tag"
-#pvchange -a --deltag 210 --deltag tag
+pvchange --addtag 306 -S "pv_name=$dev1" $dev2
+not check pv_field $dev1 pv_tags 306
+not check pv_field $dev2 pv_tags 306
+not check pv_field $dev3 pv_tags 306
+not check pv_field $dev4 pv_tags 306
+pvchange -a --deltag 306
+pvchange --addtag 307 -S "pv_name=$dev1" $dev1
+check pv_field $dev1 pv_tags 307
+not check pv_field $dev2 pv_tags 307
+not check pv_field $dev3 pv_tags 307
+not check pv_field $dev4 pv_tags 307
+pvchange -a --deltag 307
+pvchange --addtag "tag" $dev1
+pvchange --addtag 308 -S "pv_name=$dev2" @tag
+not check pv_field $dev1 pv_tags "308,tag"
+not check pv_field $dev2 pv_tags "308,tag"
+not check pv_field $dev3 pv_tags "308,tag"
+not check pv_field $dev4 pv_tags "308,tag"
+pvchange --deltag 308 $dev1
+pvchange --addtag 309 -S "pv_name=$dev1" @tag
+check pv_field $dev1 pv_tags "309,tag"
+not check pv_field $dev2 pv_tags "309,tag"
+not check pv_field $dev3 pv_tags "309,tag"
+not check pv_field $dev4 pv_tags "309,tag"
+pvchange -a --deltag 309 --deltag tag


