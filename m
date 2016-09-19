From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:35 +0000 (UTC)
Subject: master - lvmdbustest: Remove pyudev deprecated warnings
Message-ID: <20160919203835.BCB60609C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d18ea3f2cbbc53952f69ad52ca39835cebf4a847
Commit:        d18ea3f2cbbc53952f69ad52ca39835cebf4a847
Parent:        ec821d37a845f448230d114188f2a0d7623976dc
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 19 10:33:32 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:47 2016 -0500

lvmdbustest: Remove pyudev deprecated warnings

---
 test/dbus/lvmdbustest.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9702ee8..31902c4 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1015,7 +1015,7 @@ class TestDbusService(unittest.TestCase):
 
 		block_path = []
 		for d in devices:
-			block_path.append(d['DEVNAME'])
+			block_path.append(d.properties['DEVNAME'])
 
 		self.assertEqual(
 			self.handle_return(
@@ -1028,7 +1028,7 @@ class TestDbusService(unittest.TestCase):
 
 		mm = []
 		for d in devices:
-			mm.append((int(d['MAJOR']), int(d['MINOR'])))
+			mm.append((int(d.properties['MAJOR']), int(d.properties['MINOR'])))
 
 		self.assertEqual(
 


