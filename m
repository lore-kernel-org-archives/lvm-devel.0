From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 18 May 2017 06:57:26 -0400
Subject: master - lvmdbusd: Fix missed rename
Message-ID: <201705181057.v4IAvQJj002077@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e99a46d09ef21e9a1741eb333e16aaa08ac50f1
Commit:        8e99a46d09ef21e9a1741eb333e16aaa08ac50f1
Parent:        9c651b146ef7be080c5006f94c257e2c9815cd7f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 18 12:52:46 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 18 12:52:46 2017 +0200

lvmdbusd: Fix missed rename

Introduced By: e53454d6 (2.02.169)
Related: RHBZ#1348688
---
 daemons/lvmdbusd/automatedproperties.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index 68cea6e..e188fa4 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -100,7 +100,7 @@ class AutomatedProperties(dbus.service.Object):
 		raise dbus.exceptions.DBusException(
 			obj._ap_interface,
 			'The object %s does not implement the %s interface'
-			% (self.__class__, interface_name))
+			% (obj.__class__, interface_name))
 
 	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
 							in_signature='s', out_signature='a{sv}',


