From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 31 Mar 2015 19:46:29 +0000 (UTC)
Subject: master - tests: add clvm case to system_id.sh
Message-ID: <20150331194629.A12FC60F26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf2d831e7e9ceb7fe0528dba8587a4157b4ac789
Commit:        bf2d831e7e9ceb7fe0528dba8587a4157b4ac789
Parent:        20c6192fbb9901468fad8fe41c7a6366aa3ab6fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 31 14:45:14 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 31 14:45:14 2015 -0500

tests: add clvm case to system_id.sh

---
 test/shell/system_id.sh |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index ad8871a..e1d8967 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -13,11 +13,28 @@ test_description='Test system_id'
 
 . lib/inittest
 
-# Should 'system_id' be usable in cluster ??
-test -e LOCAL_CLVMD && skip
-
 aux prepare_devs 1
 
+# with clvm enabled, vgcreate with no -c option creates a clustered vg,
+# which should have no system id
+
+if [ -e LOCAL_CLVMD ]; then
+SID1=sidfoolocal
+SID2=""
+LVMLOCAL=etc/lvmlocal.conf
+rm -f $LVMLOCAL
+echo "local {" > $LVMLOCAL
+echo "  system_id = $SID1" >> $LVMLOCAL
+echo "}" >> $LVMLOCAL
+aux lvmconf "global/system_id_source = lvmlocal"
+vgcreate $vg1 "$dev1"
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID2
+vgremove $vg1
+rm -f $LVMLOCAL
+exit 0
+fi
+
 # create vg with system_id using each source
 
 ## none


