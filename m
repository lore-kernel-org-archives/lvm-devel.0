From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:42 +0000 (GMT)
Subject: main - lvmdbusd: Fix env variable LVM_DBUSD_TEST_MODE
Message-ID: <20220630160042.9ADB6386F0CE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3d7aff6a3a8fd55790f61b9b0b33d599841030b
Commit:        b3d7aff6a3a8fd55790f61b9b0b33d599841030b
Parent:        47c61907b4adbdead50f5bb5ac95c0f5d0fe263e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 16:21:14 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Fix env variable LVM_DBUSD_TEST_MODE

Make it more logical.
---
 test/dbus/lvmdbustest.py | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 3eef77fd7..d876a1748 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -40,9 +40,10 @@ pv_device_list = os.getenv('LVM_DBUSD_PV_DEVICE_LIST', None)
 
 # Default is to test all modes
 # 0 == Only test fork & exec mode
-# 1 == Test both fork & exec & lvm shell mode (default)
+# 1 == Only test lvm shell mode
+# 2 == Test both fork & exec & lvm shell mode (default)
 # Other == Test just lvm shell mode
-test_shell = os.getenv('LVM_DBUSD_TEST_MODE', 1)
+test_shell = os.getenv('LVM_DBUSD_TEST_MODE', 2)
 
 # LVM binary to use
 LVM_EXECUTABLE = os.getenv('LVM_BINARY', '/usr/sbin/lvm')
@@ -2081,16 +2082,19 @@ if __name__ == '__main__':
 	if mode == 0:
 		std_err_print('\n*** Testing only lvm fork & exec test mode ***\n')
 	elif mode == 1:
+		std_err_print('\n*** Testing only lvm shell mode ***\n')
+	elif mode == 2:
 		std_err_print('\n*** Testing fork & exec & lvm shell mode ***\n')
 	else:
-		std_err_print('\n*** Testing only lvm shell mode ***\n')
+		std_err_print("Unsupported \"LVM_DBUSD_TEST_MODE\"=%d, [0-2] valid" % mode)
+		sys.exit(1)
 
 	for g_tmo in [0, 15]:
 		std_err_print('Testing TMO=%d\n' % g_tmo)
 		if mode == 0:
 			if set_execution(False, r):
 				r.register_result(unittest.main(exit=False))
-		elif mode == 2:
+		elif mode == 1:
 			if set_execution(True, r):
 				r.register_result(unittest.main(exit=False))
 		else:

