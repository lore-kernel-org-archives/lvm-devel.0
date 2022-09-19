From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:37 +0000 (GMT)
Subject: main - lvmdbustest: Check for self.pvs
Message-ID: <20220919155837.A4C053858294@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a326e35cda10b922dfa29d27e9c03e3b56282ba5
Commit:        a326e35cda10b922dfa29d27e9c03e3b56282ba5
Parent:        ead80d134dd6afb288453bd20c5ab25daa450b06
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:29:55 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Check for self.pvs

If we don't make it through setUp, self.pvs will not exist.
---
 test/dbus/lvmdbustest.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 18cac35d6..045dbb2b0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -454,7 +454,7 @@ class TestDbusService(unittest.TestCase):
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
 		self.objs, self.bus = get_objects()
-		if len(self.pvs) != len(self.objs[PV_INT]):
+		if hasattr(self, "pvs") and len(self.pvs) != len(self.objs[PV_INT]):
 			for p in self.pvs:
 				found = False
 				for pc in self.objs[PV_INT]:

