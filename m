From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:50 +0000 (GMT)
Subject: main - lvmdbustest: Increase number of LVs
Message-ID: <20220630160050.88D8C386F0D8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73121e3f0712d228e713b71468484ca55d62d93b
Commit:        73121e3f0712d228e713b71468484ca55d62d93b
Parent:        8fa8dfdb8c3b5310a5b43c99fd088f4f076b5903
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 10:01:18 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbustest: Increase number of LVs

As storage is getting faster, we need to create more LVs to pass this test.
---
 test/dbus/lvmdbustest.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ae02c5fef..12f1741b1 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1170,7 +1170,7 @@ class TestDbusService(unittest.TestCase):
 				return
 
 		# This may not pass
-		for i in [64, 128]:
+		for i in [128, 256]:
 			yes = self._test_expired_timer(i)
 			if yes:
 				break

