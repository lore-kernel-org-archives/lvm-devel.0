From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 22 Feb 2016 22:11:02 +0000 (UTC)
Subject: master - lvmdbusd: Add env variable to use session bus
Message-ID: <20160222221102.A778560D5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21034644b6582a6d9ad571ff51cc57ad5e08b9ff
Commit:        21034644b6582a6d9ad571ff51cc57ad5e08b9ff
Parent:        64aab5885d7afdbd63979b6f8520564ad2eb59ac
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 22 14:28:11 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 22 16:07:54 2016 -0600

lvmdbusd: Add env variable to use session bus

export LVMDBUSD_SESSION=True to run on the session bus instead
of the system bus so that we can run the unit test without
installing the dbus conf file.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/main.py |    9 ++++++++-
 test/dbus/lvmdbustest.py |    7 ++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 43545b2..c9211f7 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -28,6 +28,7 @@ import sys
 from . import udevwatch
 from .utils import log_debug
 import argparse
+import os
 
 
 class Lvm(objectmanager.ObjectManager):
@@ -71,6 +72,8 @@ def main():
 						help="Dump debug messages", default=False,
 						dest='debug')
 
+	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+
 	args = parser.parse_args()
 
 	cfg.DEBUG = args.debug
@@ -90,7 +93,11 @@ def main():
 	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
 	GObject.threads_init()
 	dbus.mainloop.glib.threads_init()
-	cfg.bus = dbus.SystemBus()
+
+	if use_session:
+		cfg.bus = dbus.SessionBus()
+	else:
+		cfg.bus = dbus.SystemBus()
 	# The base name variable needs to exist for things to work.
 	# noinspection PyUnusedLocal
 	base_name = dbus.service.BusName(BASE_INTERFACE, cfg.bus)
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 16fffdf..92f5d70 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -44,7 +44,12 @@ def rs(length, suffix, character_set=string.ascii_lowercase):
 				for _ in range(length)) + suffix
 
 
-bus = dbus.SystemBus(mainloop=DBusGMainLoop())
+use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+
+if use_session:
+	bus = dbus.SessionBus(mainloop=DBusGMainLoop())
+else:
+	bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
 def mib(s):


