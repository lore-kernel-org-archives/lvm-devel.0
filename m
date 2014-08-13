From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Aug 2014 15:20:38 +0000 (UTC)
Subject: master - tests: update report-select test for latest changes
Message-ID: <20140813152038.342126114B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20503ff0675616823bcc9aa67f3e6d14a4172277
Commit:        20503ff0675616823bcc9aa67f3e6d14a4172277
Parent:        fa793bed64a728185a9f8aa6196f0d411f89daf5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 13 17:19:58 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 13 17:20:09 2014 +0200

tests: update report-select test for latest changes

---
 test/shell/report-select.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index cdd45ed..fb12bd6 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -106,7 +106,7 @@ lvs_sel "lv_name='vol1'" "vol1"
 ###############################
 # STRING LIST FIELD SELECTION #
 ###############################
-pvs_sel 'tags=["pv_tag1"]' "$dev1 $dev2"
+pvs_sel 'tags=["pv_tag1"]' ""
 # for one item, no need to use []
 pvs_sel 'tags="pv_tag1"' "$dev1 $dev2"
 # no match
@@ -115,7 +115,7 @@ pvs_sel 'tags=["pv_tag1" && "pv_tag2" && "pv_tag3"]' "$dev1"
 # check the order has no effect on selection result
 pvs_sel 'tags=["pv_tag3" && "pv_tag2" && "pv_tag1"]' "$dev1"
 pvs_sel 'tags=["pv_tag4" || "pv_tag3"]' "$dev1 $dev6"
-pvs_sel 'tags!=["pv_tag1"]' "$dev2 $dev3 $dev4 $dev5"
+pvs_sel 'tags!=["pv_tag1"]' "$dev1 $dev2 $dev3 $dev4 $dev5 $dev6"
 # check mixture of && and || - this is not allowed
 not pvs_sel 'tags=["pv_tag1" && "pv_tag2" || "pv_tag3"]'
 


