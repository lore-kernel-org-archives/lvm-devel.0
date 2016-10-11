From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 11 Oct 2016 18:18:49 +0000 (UTC)
Subject: master - lvmdbustest.py: Use more compatible syntax
Message-ID: <20161011181849.7DECB60DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=595af62ebd8eca6b95266f617df67528f3b70fd8
Commit:        595af62ebd8eca6b95266f617df67528f3b70fd8
Parent:        4fab8339207fd8846e04e775897a7ba7a3cd074c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 11 10:43:41 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 11 13:16:57 2016 -0500

lvmdbustest.py: Use more compatible syntax

---
 test/dbus/lvmdbustest.py |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d222264..1991c94 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -29,8 +29,9 @@ else:
 	bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
-def std_err_print(*args, **kwargs):
-	print(*args, file=sys.stderr, **kwargs)
+def std_err_print(*args):
+	sys.stderr.write(' '.join(map(str, args)) + '\n')
+	sys.stderr.flush()
 
 
 def get_objects():


