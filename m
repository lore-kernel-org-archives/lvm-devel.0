From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:51 -0400
Subject: master - lvmdbusd: Add check for reserved name '_vdata'
Message-ID: <201910301543.x9UFhpc9016572@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bafe5d15b1e3c1e31b9c4c32cd875dc5dfe2a2fb
Commit:        bafe5d15b1e3c1e31b9c4c32cd875dc5dfe2a2fb
Parent:        b7c64fe8e29ffc003364da93047b9e003c35fc96
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 12:19:07 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Add check for reserved name '_vdata'

Added for vdo support.
---
 daemons/lvmdbusd/utils.py |    2 +-
 test/dbus/lvmdbustest.py  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 8d64117..40b8a68 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -455,7 +455,7 @@ _ALLOWABLE_CH_SET = set(_ALLOWABLE_CH)
 _ALLOWABLE_VG_LV_CH = string.ascii_letters + string.digits + '.-_+'
 _ALLOWABLE_VG_LV_CH_SET = set(_ALLOWABLE_VG_LV_CH)
 _LV_NAME_RESERVED = ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
-	"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin")
+	"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin", "_vdata")
 
 # Tags can have the characters, based on the code
 # a-zA-Z0-9._-+/=!:&#
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4ae8b25..31dc4ff 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1670,7 +1670,7 @@ class TestDbusService(unittest.TestCase):
 		for reserved in (
 				"_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
 				"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta",
-				"_vorigin"):
+				"_vorigin", "_vdata"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(


