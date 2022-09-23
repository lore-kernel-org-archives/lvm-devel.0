From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 23 Sep 2022 12:59:04 +0000 (GMT)
Subject: main - lvmdbustest: Refuse to remove a VG we didn't create
Message-ID: <20220923125904.62A02385734F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7966f1dd18ab88199da7dd0d84a44945c2f864ca
Commit:        7966f1dd18ab88199da7dd0d84a44945c2f864ca
Parent:        40018cbf5386e4ba76c0d4cc10aa1bd88ef0e6ab
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 22 16:18:48 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 22 16:19:16 2022 -0500

lvmdbustest: Refuse to remove a VG we didn't create

One of our previous commits introduced the side effect that we could
inadvertently remove a VG we didn't create, and lose data.
---
 test/dbus/lvmdbustest.py | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index fc84026df..9b1024db3 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -410,9 +410,13 @@ class TestDbusService(unittest.TestCase):
 		self.vdo = supports_vdo()
 
 	def _recurse_vg_delete(self, vg_proxy, pv_proxy, nested_pv_hash):
+		vg_name = str(vg_proxy.Vg.Name)
+
+		if not vg_name.endswith(VG_TEST_SUFFIX):
+			std_err_print("Refusing to remove VG: %s" % vg_name)
+			return
 
 		for pv_device_name, t in nested_pv_hash.items():
-			vg_name = str(vg_proxy.Vg.Name)
 			if vg_name in pv_device_name:
 				self._recurse_vg_delete(t[0], t[1], nested_pv_hash)
 				break

