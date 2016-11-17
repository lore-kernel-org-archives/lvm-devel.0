From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:38 +0000 (UTC)
Subject: master - lvmdbusd: Add cfg.load to pv remove
Message-ID: <20161117173638.59C3060D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcdef9647b8de6aa958ad988de038c067a1f7199
Commit:        dcdef9647b8de6aa958ad988de038c067a1f7199
Parent:        24fd1dd7a3ac3f9692e2a561c8cd10bdd0d32d96
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 10:45:31 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Add cfg.load to pv remove

The global dbus state does not match lvm with simply removing the pv
dbus object.
---
 daemons/lvmdbusd/pv.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index fa07f98..95047d1 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -18,7 +18,7 @@ from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
 from .loader import common
 from .request import RequestEntry
 from .state import State
-from .utils import round_size, mt_remove_dbus_objects
+from .utils import round_size
 
 
 # noinspection PyUnusedLocal
@@ -140,7 +140,7 @@ class Pv(AutomatedProperties):
 		if dbo:
 			rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
 			if rc == 0:
-				mt_remove_dbus_objects((dbo,))
+				cfg.load()
 			else:
 				# Need to work on error handling, need consistent
 				raise dbus.exceptions.DBusException(


