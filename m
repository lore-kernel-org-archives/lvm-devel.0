From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 23 Sep 2022 12:59:05 +0000 (GMT)
Subject: main - lvmdbustest: Re-work setUp
Message-ID: <20220923125905.838413857363@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=897b326cccc017b9e033b83d24ddcb007a3922f4
Commit:        897b326cccc017b9e033b83d24ddcb007a3922f4
Parent:        7966f1dd18ab88199da7dd0d84a44945c2f864ca
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 22 17:10:13 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 22 17:10:13 2022 -0500

lvmdbustest: Re-work setUp

Place the addCleanup at the end as we don't want to go through clean up
if we don't make it through setUp.  If we don't do this we can remove VGs
that we didn't create in the unit test.
---
 test/dbus/lvmdbustest.py | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9b1024db3..cf50bc564 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -385,8 +385,7 @@ class DaemonInfo(object):
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
 	def setUp(self):
-
-		self.addCleanup(self.clean_up)
+		self.pvs = []
 
 		# Because of the sensitive nature of running LVM tests we will only
 		# run if we have PVs and nothing else, so that we can be confident that
@@ -395,6 +394,10 @@ class TestDbusService(unittest.TestCase):
 		if len(self.objs[PV_INT]) == 0:
 			std_err_print('No PVs present exiting!')
 			sys.exit(1)
+
+		for p in self.objs[PV_INT]:
+			self.pvs.append(p.Pv.Name)
+
 		if len(self.objs[MANAGER_INT]) != 1:
 			std_err_print('Expecting a manager object!')
 			sys.exit(1)
@@ -403,9 +406,7 @@ class TestDbusService(unittest.TestCase):
 			std_err_print('Expecting no VGs to exist!')
 			sys.exit(1)
 
-		self.pvs = []
-		for p in self.objs[PV_INT]:
-			self.pvs.append(p.Pv.Name)
+		self.addCleanup(self.clean_up)
 
 		self.vdo = supports_vdo()
 
@@ -460,7 +461,7 @@ class TestDbusService(unittest.TestCase):
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
 		self.objs, self.bus = get_objects()
-		if hasattr(self, "pvs") and len(self.pvs) != len(self.objs[PV_INT]):
+		if len(self.pvs) != len(self.objs[PV_INT]):
 			for p in self.pvs:
 				found = False
 				for pc in self.objs[PV_INT]:

