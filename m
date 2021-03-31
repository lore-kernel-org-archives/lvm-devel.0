From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:39 +0000 (GMT)
Subject: dev-next - tests: restore removed prefix
Message-ID: <20210331214939.994133858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f7bd719d0d31a5dd5886dfcf783f6c2e80cb2e8
Commit:        1f7bd719d0d31a5dd5886dfcf783f6c2e80cb2e8
Parent:        12222add1abb45ebbc0c6dfccb514bb75d4ae4ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 27 21:58:33 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 27 23:19:08 2021 +0100

tests: restore removed prefix

During debugging this prefix was unintentionally lost, restore.
---
 test/dbus/lvmdbustest.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 746025903..03d5ba5aa 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -341,7 +341,7 @@ class TestDbusService(unittest.TestCase):
 		if not pv_paths:
 			pv_paths = self._all_pv_object_paths()
 
-		vg_name = vg_n()
+		vg_name = vg_n(prefix=vg_prefix)
 
 		vg_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.VgCreate(


