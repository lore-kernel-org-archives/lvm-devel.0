From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 26 Apr 2017 09:36:37 -0400
Subject: master - lvmdbusd: Improve error msg to include PV
Message-ID: <201704261336.v3QDabI2009061@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f31f10ac5881b2780b0083f5e45fed59aeb8013
Commit:        0f31f10ac5881b2780b0083f5e45fed59aeb8013
Parent:        e50fb06792518ff9a5a299172b77e9d22105d372
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Apr 22 00:07:52 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Apr 26 07:31:08 2017 -0500

lvmdbusd: Improve error msg to include PV

Include PV device path when we believe it already exists.
---
 daemons/lvmdbusd/manager.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 5bcdbb8..1ae9c8b 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -48,7 +48,7 @@ class Manager(AutomatedProperties):
 		pv = cfg.om.get_object_path_by_uuid_lvm_id(device, device)
 		if pv:
 			raise dbus.exceptions.DBusException(
-				MANAGER_INTERFACE, "PV Already exists!")
+				MANAGER_INTERFACE, "PV %s Already exists!" % device)
 
 		rc, out, err = cmdhandler.pv_create(create_options, [device])
 		Manager.handle_execute(rc, out, err)


