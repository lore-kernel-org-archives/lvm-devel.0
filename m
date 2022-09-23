From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 23 Sep 2022 12:59:03 +0000 (GMT)
Subject: main - lvmdbustest: Make vg name suffix more unique
Message-ID: <20220923125903.3FB8F385735F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40018cbf5386e4ba76c0d4cc10aa1bd88ef0e6ab
Commit:        40018cbf5386e4ba76c0d4cc10aa1bd88ef0e6ab
Parent:        36a8fb20bf8a42e7e3227ad85a2b29e0b1432b14
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 22 16:17:20 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 22 16:17:20 2022 -0500

lvmdbustest: Make vg name suffix more unique

---
 test/dbus/lvmdbustest.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 045dbb2b0..fc84026df 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -29,6 +29,8 @@ g_tmo = 0
 # Approx. min size
 VDO_MIN_SIZE = mib(8192)
 
+VG_TEST_SUFFIX = "_vg_LvMdBuS_TEST"
+
 EXE_NAME="/lvmdbusd"
 
 # Prefix on created objects to enable easier clean-up
@@ -71,7 +73,7 @@ if pv_device_list:
 
 
 def vg_n(prefix=None):
-	name = rs(8, '_vg')
+	name = rs(8, VG_TEST_SUFFIX)
 	if prefix:
 		name = prefix + name
 	return g_prefix + name

