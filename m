From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:34 +0000 (GMT)
Subject: main - lvmdbustest: Don't use hard coded /tmp for error inject log
Message-ID: <20230310185234.639473858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=568e8c71d7e39da7494a470400d3f9977c13a1c7
Commit:        568e8c71d7e39da7494a470400d3f9977c13a1c7
Parent:        66e79aab367621cbe76bf1e080d6f8693922ea07
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 10 10:41:20 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Don't use hard coded /tmp for error inject log

---
 test/dbus/lvm_error_inject.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index d00b79b05..2849dd29c 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -42,7 +42,7 @@ def rs(length, character_set=CS):
 
 RS = rs(512)
 
-d_out = open("/tmp/mitm_lvm.txt", "a")
+d_out = open(os.path.join(tempfile.gettempdir(), "mitm_lvm.txt"), "a")
 
 
 def debug(msg):

