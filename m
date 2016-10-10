From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:22 +0000 (UTC)
Subject: master - lvmdbustest.py: Skip test_job_handling_timer on loopback
Message-ID: <20161010213522.F2E2160C40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be06fa695ea9833bcc25c09a17c6396cca07be31
Commit:        be06fa695ea9833bcc25c09a17c6396cca07be31
Parent:        3e45285b403bdcbf744f21eba6d6aa3a70628e71
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 18:18:36 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbustest.py: Skip test_job_handling_timer on loopback

This test never passes on loop back, so we will skip unless the
pv devices are real devices which contain `/dev/sd`.

We always fail because we need lvm to run slow to get a timer to
pop, and loopback are too fast.
---
 test/dbus/lvmdbustest.py |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 37ce1d4..d222264 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -807,6 +807,11 @@ class TestDbusService(unittest.TestCase):
 
 		yes = False
 
+		for pp in self.objs[PV_INT]:
+			if '/dev/sd' not in pp.Pv.Name:
+				std_err_print("Skipping test_job_handling_timer on loopback")
+				return
+
 		# This may not pass
 		for i in [48, 64, 128]:
 			yes = self._test_expired_timer(i)


