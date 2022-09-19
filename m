From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:06 +0000 (GMT)
Subject: main - lvmdbusd: Correct typos
Message-ID: <20220919155806.EB6AA385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec50979b031e85ab155126aae51ab15b255f4be9
Commit:        ec50979b031e85ab155126aae51ab15b255f4be9
Parent:        3d8882db833909bede4b8cbcc81c1c3b9d9b3515
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:24:37 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Correct typos

---
 daemons/lvmdbusd/lvmdb.py.in | 2 +-
 test/dbus/lvmdbustest.py     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 87474d0f3..d462e0cf8 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -161,7 +161,7 @@ class DataStore(object):
 		c_lvs = OrderedDict()
 		c_lv_full_lookup = {}
 
-		# Each item item in the report is a collection of information pertaining
+		# Each item in the report is a collection of information pertaining
 		# to the vg
 		for r in _all['report']:
 			# Get the lv data for this VG.
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 878300a97..c4e95b7cc 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -215,7 +215,7 @@ class TestDbusService(unittest.TestCase):
 	def setUp(self):
 		# Because of the sensitive nature of running LVM tests we will only
 		# run if we have PVs and nothing else, so that we can be confident that
-		# we are not mucking with someones data on their system
+		# we are not mucking with someone's data on their system
 		self.objs, self.bus = get_objects()
 		if len(self.objs[PV_INT]) == 0:
 			std_err_print('No PVs present exiting!')

