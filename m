From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:31 +0000 (GMT)
Subject: main - lvmdbustest: Utilize addCleanup in unit test
Message-ID: <20220919155831.EF8C8385828E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6dc96d8ef03e7af6624ab88a94654ffa94c50ba
Commit:        b6dc96d8ef03e7af6624ab88a94654ffa94c50ba
Parent:        e977b70bfb0a26a8dd5cd06d581cb810e2a6f10b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 18:03:16 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Utilize addCleanup in unit test

Register the clean up with addCleanup so we ensure clean_up gets run
regardless of what happens in setUp.
---
 test/dbus/lvmdbustest.py | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c932d0830..0d06177c0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -383,6 +383,9 @@ class DaemonInfo(object):
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
 	def setUp(self):
+
+		self.addCleanup(self.clean_up)
+
 		# Because of the sensitive nature of running LVM tests we will only
 		# run if we have PVs and nothing else, so that we can be confident that
 		# we are not mucking with someone's data on their system
@@ -463,11 +466,6 @@ class TestDbusService(unittest.TestCase):
 					# print('Re-creating PV=', p)
 					self._pv_create(p)
 
-	def tearDown(self):
-		# If we get here it means we passed setUp, so lets remove anything
-		# and everything that remains, besides the PVs themselves
-		self.clean_up()
-
 	def _check_consistency(self):
 		# Only do consistency checks if we aren't running the unit tests
 		# concurrently

