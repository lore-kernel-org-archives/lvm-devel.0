From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 18:03:42 -0500
Subject: master - tests: have some space for 2nd mda
Message-ID: <201711072303.vA7N3gk2030260@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2172115379386b63fca2f31337dcb0e2e92ac4c0
Commit:        2172115379386b63fca2f31337dcb0e2e92ac4c0
Parent:        f7fc7bc44a6e63f06363e27ca9f3b499d9a39eee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 7 23:17:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 8 00:02:54 2017 +0100

tests: have some space for 2nd mda

pvcreate with 2MDAs needs some extra space.
---
 test/api/python_lvm_unit.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 75c370e..3ffb3ad 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -902,7 +902,7 @@ class TestLvm(unittest.TestCase):
 			lvm.pvCreate(d)
 
 	def test_pv_create(self):
-		size = [0, 1024 * 1024 * 4]
+		size = [0, 1024 * 1024 * 8]
 		pvmeta_copies = [0, 1, 2]
 		pvmeta_size = [0, 255, 512, 1024]
 		data_alignment = [0, 2048, 4096]


