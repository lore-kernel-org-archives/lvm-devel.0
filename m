From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:44:31 +0000 (UTC)
Subject: master - lvmdbusd testing: Add validatestate.py utility
Message-ID: <20160225224431.0E01B6109D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26b826ccf59b891a7947d9f7f2bacf8d0a5172a9
Commit:        26b826ccf59b891a7947d9f7f2bacf8d0a5172a9
Parent:        0d620e681fe42d0a1b2a5666677c36753838c6fd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 25 16:12:53 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Feb 25 16:43:55 2016 -0600

lvmdbusd testing: Add validatestate.py utility

This simple tool calls the Manager.Refresh method on the dbus service
to check and see if the dbus service has the most up to date state.
This is to be used for testing to ensure that event driven updates are
working as planned.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/validatestate.py |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/test/dbus/validatestate.py b/test/dbus/validatestate.py
new file mode 100755
index 0000000..faa2083
--- /dev/null
+++ b/test/dbus/validatestate.py
@@ -0,0 +1,32 @@
+#!/usr/bin/env python3
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+# Simply connects to the dbus service and calls Refresh and ensures that the
+# value returned is zero
+
+import testlib
+import dbus
+from dbus.mainloop.glib import DBusGMainLoop
+import sys
+import os
+
+
+if __name__ == "__main__":
+
+	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+
+	if use_session:
+		bus = dbus.SessionBus(mainloop=DBusGMainLoop())
+	else:
+		bus = dbus.SystemBus(mainloop=DBusGMainLoop())
+
+	mgr_proxy = testlib.ClientProxy(bus, testlib.MANAGER_OBJ)
+	sys.exit(mgr_proxy.Manager.Refresh())


