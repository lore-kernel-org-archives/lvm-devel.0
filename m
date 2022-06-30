From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:48 +0000 (GMT)
Subject: main - lvmdbustest: Test job remove path when job not complete
Message-ID: <20220630160048.49386386F0D4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55059e002abb3d858e4c53ac0da078ca853ff1f4
Commit:        55059e002abb3d858e4c53ac0da078ca853ff1f4
Parent:        d393436727014b9eddf71009065f65a59ff3837c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 09:58:39 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbustest: Test job remove path when job not complete

---
 test/dbus/lvmdbustest.py | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d876a1748..e16a484b7 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -886,8 +886,19 @@ class TestDbusService(unittest.TestCase):
 				j.Remove()
 
 				break
+			else:
+				# Most of the time we will get this exception as expected, but there is
+				# a race condition between checking if it's complete and removing it (we want to try to remove while
+				# it's not complete to raise the exception)
+				# Thus, we can't reliably use self.assertRaises.
+				# We have included it here to test this path in the daemon.
+				try:
+					j.Remove()
+				except dbus.exceptions.DBusException:
+					pass
 
 			if j.Wait(1):
+				self.assertTrue(j.Wait(0))
 				j.update()
 				self.assertTrue(j.Complete)
 

