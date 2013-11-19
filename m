From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:33 +0000 (UTC)
Subject: master - python-lvm: Test case change for vg.reduce
Message-ID: <20131119205633.3A68D60EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec7f632ce08014ca5ceb3ac6c92d834fb0b8c93e
Commit:        ec7f632ce08014ca5ceb3ac6c92d834fb0b8c93e
Parent:        5074dcc896681494309c59830803b54a84429fd0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 10 17:59:45 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:32 2013 -0600

python-lvm: Test case change for vg.reduce

Fix reduce as newly changed vg reduce fails when you
try to remove the last pv in the vg.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index bceb82c..eab9575 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -185,7 +185,7 @@ class TestLvm(unittest.TestCase):
 		for p in pvs:
 			pe_devices.append(p.getName())
 
-		for pv in pe_devices:
+		for pv in pe_devices[:-1]:
 			vg.reduce(pv)
 
 		vg.remove()


