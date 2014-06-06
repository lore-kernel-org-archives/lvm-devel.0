From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:16 +0000 (UTC)
Subject: dev-prajnoha-report-select - tests: adapt test for newline delimit
Message-ID: <20140606120316.A55EC60FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb7ca96b5901d3bf70f0ba193bee55fc616b1805
Commit:        eb7ca96b5901d3bf70f0ba193bee55fc616b1805
Parent:        46b0cd10fe2405f281651fcfea5f536573fa7cbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 23:05:52 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 23:05:52 2014 +0200

tests: adapt test for newline delimit

content of DEVICES is now delimited by newlines
---
 test/api/python_lvm_unit.py  |    2 +-
 test/shell/lvconvert-thin.sh |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 8208d91..39a6779 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -51,7 +51,7 @@ def rs(rand_len=10):
 def _get_allowed_devices():
 	rc = os.environ.get('PY_UNIT_PVS')
 	if rc is not None:
-		rc = rc.split(' ')
+		rc = rc.splitlines()
 		rc.sort()
 	return rc
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 8c3b903..a7bbe9f 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -27,7 +27,7 @@ aux have_thin 1 0 0 || skip
 aux prepare_pvs 4 64
 
 # build one large PV
-vgcreate $vg1 $(cut -d ' ' -f -3 DEVICES)
+vgcreate $vg1 $(head -n 3 DEVICES)
 # 32bit linux kernels are fragille with device size >= 16T
 # maybe  uname -m    [ x86_64 | i686 ]
 TSIZE=64T
@@ -36,7 +36,7 @@ lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
-vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
+vgcreate $vg -s 64K $(tail -n+4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
 
 # create mirrored LVs for data and metadata volumes
 lvcreate -aey -L10M --type mirror -m1 --mirrorlog core -n $lv1 $vg


