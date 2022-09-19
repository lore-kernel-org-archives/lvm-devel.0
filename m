From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:13 +0000 (GMT)
Subject: main - lvmdbustest: Add systemctl daemon start
Message-ID: <20220919155813.BE2933858429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9693709b4642c7ef0c82f117b4f776a1e688d851
Commit:        9693709b4642c7ef0c82f117b4f776a1e688d851
Parent:        f252e05aaeb1a34598cc9d93e3c65ce2e311621b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:54:22 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add systemctl daemon start

---
 test/dbus/lvmdbustest.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 72a75edea..ba93379dc 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -278,7 +278,7 @@ class DaemonInfo(object):
 
 	def start(self, expect_fail=False):
 		if self.systemd:
-			pass
+			subprocess.run(["/usr/bin/systemctl", "start", "lvm2-lvmdbusd"], check=True)
 		else:
 			stdin_stream = None
 			stdout_stream = None

