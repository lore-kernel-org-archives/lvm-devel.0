From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:53 +0000 (UTC)
Subject: master - lvmdbusd: Include lvm shell testing as the default
Message-ID: <20160829202853.5CCAC601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d1fe008468bfbab7285b0a559803cf351472e7c
Commit:        1d1fe008468bfbab7285b0a559803cf351472e7c
Parent:        313c40ed09d4eedba208a50c783d8d20e32de92e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 13:19:01 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd: Include lvm shell testing as the default

---
 test/dbus/lvmdbustest.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ced49a0..4d0143c 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1153,7 +1153,7 @@ class TestDbusService(unittest.TestCase):
 
 if __name__ == '__main__':
 	# Test forking & exec new each time
-	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 0)
+	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 1)
 
 	set_execution(False)
 


