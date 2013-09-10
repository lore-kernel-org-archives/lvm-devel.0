From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 10 Sep 2013 18:12:59 -0500
Subject: [PATCH 1/3] python-lvm: Test case change for vg.reduce
Message-ID: <1378854781-16339-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix reduce as newly changed vg reduce fails when you
try to remove the last pv in the vg.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
-- 
1.8.2.1


