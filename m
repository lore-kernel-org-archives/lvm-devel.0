From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:41 -0500
Subject: master - lvmdbustest.py: Remove un-used `import time`
Message-ID: <201703092241.v29MffUE015971@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92b7c329ee6524fdf868a4261025406445744b12
Commit:        92b7c329ee6524fdf868a4261025406445744b12
Parent:        0c0002d7659ef27fcb7c8cf21b6b86d62e955499
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:49:40 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Remove un-used `import time`

---
 test/dbus/lvmdbustest.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 58d8d10..71b62e1 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -14,7 +14,6 @@ import dbus
 # noinspection PyUnresolvedReferences
 from dbus.mainloop.glib import DBusGMainLoop
 import unittest
-import time
 import pyudev
 from testlib import *
 import testlib


