From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:50 +0000 (UTC)
Subject: master - lvmdbustest.py: Rename env test variable
Message-ID: <20161130215950.A2D826063C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad7fd775f2b7d2d8fa9fe9bbec5101d9ecda9a92
Commit:        ad7fd775f2b7d2d8fa9fe9bbec5101d9ecda9a92
Parent:        ea2eb2df97252a5dc0f7fd27018171162d1e07ce
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 14:58:29 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbustest.py: Rename env test variable

Use LVM_DBUSD_TEST_MODE env variable to customize what we test.
Default is the same where we try to test all combinations of all
modes.  Renamed to make it consistent with the other env variables
that are used in the unit test.
---
 test/dbus/lvmdbustest.py |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 2e3ec22..af4fef1 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -30,6 +30,12 @@ use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
 # Only use the devices listed in the ENV variable
 pv_device_list = os.getenv('LVM_DBUSD_PV_DEVICE_LIST', None)
 
+# Default is to test all modes
+# 0 == Only test fork & exec mode
+# 1 == Test both fork & exec & lvm shell mode (default)
+# Other == Test just lvm shell mode
+test_shell = os.getenv('LVM_DBUSD_TEST_MODE', 1)
+
 # Empty options dictionary (EOD)
 EOD = dbus.Dictionary({}, signature=dbus.Signature('sv'))
 # Base interfaces on LV objects
@@ -1661,10 +1667,6 @@ class AggregateResults(object):
 if __name__ == '__main__':
 
 	r = AggregateResults()
-
-	# Default is to test all modes
-	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 1)
-
 	mode = int(test_shell)
 
 	if mode == 0:


