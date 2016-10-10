From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:18 +0000 (UTC)
Subject: master - lvmdbustest.py: Print to stderr
Message-ID: <20161010213518.B0E7960E2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c51f369a49f489d082c5439967eb6ca49e9a7fd
Commit:        0c51f369a49f489d082c5439967eb6ca49e9a7fd
Parent:        cb4e26dcb3aa49128d76eb61495c2ee165974ad9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 15:09:30 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbustest.py: Print to stderr

It's easier to follow if we print to stderr, so that our print messages
are in the lvm error log in the correct position to other printed
messages.
---
 test/dbus/lvmdbustest.py |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e9b27a0..ef2c07a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -29,6 +29,10 @@ else:
 	bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
+def std_err_print(*args, **kwargs):
+	print(*args, file=sys.stderr, **kwargs)
+
+
 def get_objects():
 	rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
 			THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
@@ -63,14 +67,14 @@ class TestDbusService(unittest.TestCase):
 		# we are not mucking with someones data on their system
 		self.objs, self.bus = get_objects()
 		if len(self.objs[PV_INT]) == 0:
-			print('No PVs present exiting!')
+			std_err_print('No PVs present exiting!')
 			sys.exit(1)
 		if len(self.objs[MANAGER_INT]) != 1:
-			print('Expecting a manager object!')
+			std_err_print('Expecting a manager object!')
 			sys.exit(1)
 
 		if len(self.objs[VG_INT]) != 0:
-			print('Expecting no VGs to exist!')
+			std_err_print('Expecting no VGs to exist!')
 			sys.exit(1)
 
 		self.pvs = []
@@ -808,7 +812,7 @@ class TestDbusService(unittest.TestCase):
 			yes = self._test_expired_timer(i)
 			if yes:
 				break
-			print('Attempt (%d) failed, trying again...' % (i))
+			std_err_print('Attempt (%d) failed, trying again...' % (i))
 
 		self.assertTrue(yes)
 
@@ -918,7 +922,7 @@ class TestDbusService(unittest.TestCase):
 		# TODO renable test case when
 		# https://bugzilla.redhat.com/show_bug.cgi?id=1264169 gets fixed
 		# This was tested with lvmetad disabled and we passed
-		print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
+		std_err_print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
 
 		if False:
 			vg = self._vg_create().Vg
@@ -1320,22 +1324,22 @@ if __name__ == '__main__':
 	set_execution(False)
 
 	if int(test_shell) == 0:
-		print('\n Shortened fork & exec test ***\n')
+		std_err_print('\n Running only lvm fork & exec test ***\n')
 		r.register_result(unittest.main(exit=False))
 	else:
-		print('\n *** Testing fork & exec *** \n')
+		std_err_print('\n *** Testing with lvm fork & exec *** \n')
 		r.register_result(unittest.main(exit=False))
 		g_tmo = 15
 		r.register_result(unittest.main(exit=False))
 		# Test lvm shell
-		print('\n *** Testing lvm shell *** \n')
+		std_err_print('\n *** Testing with lvm shell *** \n')
 		if set_execution(True):
 			g_tmo = 0
 			r.register_result(unittest.main(exit=False))
 			g_tmo = 15
 			r.register_result(unittest.main(exit=False))
 		else:
-			print("WARNING: Unable to dynamically configure "
+			std_err_print("ERROR: Unable to dynamically configure "
 				"service to use lvm shell!")
 
 	r.exit_run()


