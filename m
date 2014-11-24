From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 13:50:07 +0000 (UTC)
Subject: master - tests: use proper LVMTEST prefix for VG name
Message-ID: <20141124135007.B8DAB613B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74e6135c4f06f922672a057e7c47f513e84d035d
Commit:        74e6135c4f06f922672a057e7c47f513e84d035d
Parent:        1e80265c368f135bf7a92c5bb4ed49948a76f712
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 00:44:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 14:39:04 2014 +0100

tests: use proper LVMTEST prefix for VG name

Cleaner needs prefix to do its jobs and clean any left VG from python
test as well.
---
 test/api/python_lvm_unit.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index c338775..2f22fae 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -103,7 +103,7 @@ class AllowedPVS(object):
 
 class TestLvm(unittest.TestCase):
 
-	VG_P = 'py_unit_test_'
+	VG_P = os.environ.get('PREFIX')
 
 	@staticmethod
 	def _get_pv_device_names():


