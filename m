From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:51 +0000 (GMT)
Subject: main - lvmdbustest: Remove force exception in _wait_for_job
Message-ID: <20220919155751.156DE3858C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea45ba753eaa168429b9747500e6f31f2856890f
Commit:        ea45ba753eaa168429b9747500e6f31f2856890f
Parent:        3fdf4493481ff8baae2ac5416dce6d05b69e6b28
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 9 17:36:54 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbustest: Remove force exception in _wait_for_job

We put this in to test one of the paths in the damon, but unfortunately
if we hit the race condition where the job actually is done we will try
to call j.Wait(1) after the remove.  This fails with:

dbus.exceptions.DBusException: org.freedesktop.DBus.Error.UnknownMethod:
Method "Wait" with signature "i" on interface "com.redhat.lvmdbus1.Job"
doesn't exist

Which is caused by the dbus object no longer existing.  We could handle
this, but the issue is we no longer have the ability to get the result to
return, they have been lost.

A better solution would be to write a specific unit test to force this code
path and handle all the possible outcomes.
---
 test/dbus/lvmdbustest.py | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 02d4d35d7..e7df238ce 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -900,16 +900,6 @@ class TestDbusService(unittest.TestCase):
 				j.Remove()
 
 				break
-			else:
-				# Most of the time we will get this exception as expected, but there is
-				# a race condition between checking if it's complete and removing it (we want to try to remove while
-				# it's not complete to raise the exception)
-				# Thus, we can't reliably use self.assertRaises.
-				# We have included it here to test this path in the daemon.
-				try:
-					j.Remove()
-				except dbus.exceptions.DBusException:
-					pass
 
 			if j.Wait(1):
 				self.assertTrue(j.Wait(0))

