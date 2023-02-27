From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 27 Feb 2023 15:09:38 +0000 (GMT)
Subject: main - lvmdbustest.py: Remove use of root_dir in glob
Message-ID: <20230227150938.1846E3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3b7395af460033493a01d222b52cf8931090f64
Commit:        e3b7395af460033493a01d222b52cf8931090f64
Parent:        1857eb9fe08924c2e4e5adfc322ee4a2ae5a2e67
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 23 12:24:39 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 27 09:07:37 2023 -0600

lvmdbustest.py: Remove use of root_dir in glob

This feature has only been in python since 10/2021.
---
 test/dbus/lvmdbustest.py | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 685acd563..b1c965bb7 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -258,9 +258,9 @@ def remove_lvm_debug():
 	# If we are running the lvmdbusd daemon and collecting lvm debug data, check and
 	# clean-up after the tests.
 	tmpdir = tempfile.gettempdir()
-	for f in glob("lvmdbusd.lvm.debug.*.log", root_dir=tmpdir):
-		fn = os.path.join(tmpdir, f)
-		os.unlink(fn)
+	fp = os.path.join(tmpdir, "lvmdbusd.lvm.debug.*.log")
+	for f in glob(fp):
+		os.unlink(f)
 
 
 class DaemonInfo(object):

