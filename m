From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 Dec 2019 09:35:44 -0500
Subject: master - tests: VDO detection in dbus tests
Message-ID: <08525.119121809353902493@us-mta-398.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a2a993d99558a719b0f4450e7b2fc8fc43bb5962
Commit:        a2a993d99558a719b0f4450e7b2fc8fc43bb5962
Parent:        2173bdb82177fc687474b72561742955cb292522
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Dec 16 11:25:37 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Dec 16 12:06:42 2019 +0100

tests: VDO detection in dbus tests

---
 test/dbus/lvmdbustest.py |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 522e3ca..8215968 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -193,11 +193,14 @@ def call_lvm(command):
 
 def supports_vdo():
 	cmd = ['segtypes']
+	modprobe = Popen(["modprobe", "kvdo"], stdout=PIPE, stderr=PIPE, close_fds=True, env=os.environ)
+	modprobe.communicate()
+	if modprobe.returncode != 0:
+		return False
 	rc, out, err = call_lvm(cmd)
-	if rc == 0:
-		if "vdo" in out:
-			return True
-	return False
+	if rc != 0 or "vdo" not in out:
+		return False
+	return True
 
 
 # noinspection PyUnresolvedReferences



