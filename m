From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 27 Sep 2016 18:33:52 +0000 (UTC)
Subject: master - lvmdbustest.py: Make sure to test for hidden lookups
Message-ID: <20160927183352.9B19160D9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d906fd520129d639c7cad27c24f88836d133f9ad
Commit:        d906fd520129d639c7cad27c24f88836d133f9ad
Parent:        063265eacda95dbc1567e647734a000c8d68c8b7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 26 22:03:12 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 27 13:28:54 2016 -0500

lvmdbustest.py: Make sure to test for hidden lookups

Test both vgname/[hidden] and vgname/hidden forms
---
 test/dbus/lvmdbustest.py |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 7a2c44f..819d096 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -337,8 +337,16 @@ class TestDbusService(unittest.TestCase):
 			if len(h_lv.HiddenLvs) > 0:
 				self._verify_hidden_lookups(h_lv, vgname)
 
-			# print("Hidden check %s %s" % (h, h_lv.Name))
 			full_name = "%s/%s" % (vgname, h_lv.Name)
+			# print("Hidden check %s" % (full_name))
+			lookup_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(lookup_path != '/')
+			self.assertTrue(lookup_path == h_lv.object_path)
+
+			# Lets's strip off the '[ ]' and make sure we can find
+			full_name = "%s/%s" % (vgname, h_lv.Name[1:-1])
+			# print("Hidden check %s" % (full_name))
+
 			lookup_path = mgr.LookUpByLvmId(full_name)
 			self.assertTrue(lookup_path != '/')
 			self.assertTrue(lookup_path == h_lv.object_path)


