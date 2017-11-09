From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 9 Nov 2017 05:32:48 -0500
Subject: master - test: Rename test nothing methods
Message-ID: <201711091032.vA9AWmE8011241@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd3b5e60a82f745030e2a976832a1490494851dc
Commit:        cd3b5e60a82f745030e2a976832a1490494851dc
Parent:        9958c4192766edb2b0f6cf7b963b72121c50b7ad
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 9 09:52:36 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 9 11:31:54 2017 +0100

test: Rename test nothing methods

These two methods might be useful for debugging, but are not testing
anything.
---
 test/api/python_lvm_unit.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 3ffb3ad..296ca14 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -264,7 +264,7 @@ class TestLvm(unittest.TestCase):
 		self.assertTrue(found)
 
 	@staticmethod
-	def test_pv_methods():
+	def _test_pv_methods():
 		with AllowedPVS() as pvs:
 			for p in pvs:
 				p.getName()
@@ -863,7 +863,7 @@ class TestLvm(unittest.TestCase):
 			vg.close()
 
 	@staticmethod
-	def test_listing():
+	def _test_listing():
 
 		env = os.environ
 


