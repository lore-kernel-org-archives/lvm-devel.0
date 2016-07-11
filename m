From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Jul 2016 13:48:04 +0000 (UTC)
Subject: master - tests: reduce amount of pvcreates
Message-ID: <20160711134804.8D7CB60B68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6336b5dedf2a7adbc32fb7ae4f7f7aa1d9cda75a
Commit:        6336b5dedf2a7adbc32fb7ae4f7f7aa1d9cda75a
Parent:        8756297a8d39d33766f1f19060749b9570d76b1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 15:29:28 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 15:29:28 2016 +0200

tests: reduce amount of pvcreates

Reduce number of evualted pvcreate commands.
Since 0 is default value used to fill missing params,
and 0 is also 1st. value in array, it's being tested.

Drop unused data_alignment_offset.
---
 test/api/python_lvm_unit.py |   21 +++------------------
 1 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index d715231..75c370e 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -906,7 +906,6 @@ class TestLvm(unittest.TestCase):
 		pvmeta_copies = [0, 1, 2]
 		pvmeta_size = [0, 255, 512, 1024]
 		data_alignment = [0, 2048, 4096]
-		data_alignment_offset = [1, 1, 1]
 		zero = [0, 1]
 
 		device_names = TestLvm._get_pv_device_names()
@@ -927,27 +926,13 @@ class TestLvm(unittest.TestCase):
 
 		#Try a number of combinations and permutations
 		for s in size:
-			lvm.pvCreate(d, s)
-			lvm.pvRemove(d)
 			for copies in pvmeta_copies:
-				lvm.pvCreate(d, s, copies)
-				lvm.pvRemove(d)
 				for pv_size in pvmeta_size:
-					lvm.pvCreate(d, s, copies, pv_size)
-					lvm.pvRemove(d)
 					for align in data_alignment:
-						lvm.pvCreate(d, s, copies, pv_size, align)
-						lvm.pvRemove(d)
-						for align_offset in data_alignment_offset:
-							lvm.pvCreate(
-								d, s, copies, pv_size, align,
-								align * align_offset)
+						for z in zero:
+							lvm.pvCreate(d, s, copies, pv_size, align,
+								     align, z)
 							lvm.pvRemove(d)
-							for z in zero:
-								lvm.pvCreate(
-									d, s, copies, pv_size, align,
-									align * align_offset, z)
-								lvm.pvRemove(d)
 
 		#Restore
 		for d in device_names:


