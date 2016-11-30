From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:46 +0000 (UTC)
Subject: master - lvmdbustest.py: Remove outdated TODOs
Message-ID: <20161130215946.72BB060D12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b75d1a591c2ad3c85b9bc25139d2044f439e8cc7
Commit:        b75d1a591c2ad3c85b9bc25139d2044f439e8cc7
Parent:        bb845cab76b6e8003673f0f4c472fff24a6ef7f4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 14:51:20 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbustest.py: Remove outdated TODOs

- We check that all properties match the introspection data.  We
don't verify values for every property as only lvm knows what they
should be.

- We are testing vg.Move
---
 test/dbus/lvmdbustest.py |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 217a641..11fa19f 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -528,7 +528,6 @@ class TestDbusService(unittest.TestCase):
 
 		if path:
 			lv = ClientProxy(self.bus, path, interfaces=proxy_interfaces)
-			# TODO verify object properties
 
 		# We are quick enough now that we can get VolumeType changes from
 		# 'I' to 'i' between the time it takes to create a RAID and it returns
@@ -885,8 +884,6 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(rc, '/')
 		self._check_consistency()
 
-		# Test Vg.Move
-		# TODO Test this more!
 		vg.update()
 		lv.update()
 


