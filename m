From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 20 Dec 2016 17:08:16 +0000 (UTC)
Subject: master - lvmdbusd: Use cfg.reload() instead of dbo.refresh
Message-ID: <20161220170816.BCE0660E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75568294be01f74ddadbf2c9bacf5d2fce219a44
Commit:        75568294be01f74ddadbf2c9bacf5d2fce219a44
Parent:        6fe6e8053a136af45174f153c00d404995af6e1c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Dec 12 16:15:12 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Dec 20 11:06:57 2016 -0600

lvmdbusd: Use cfg.reload() instead of dbo.refresh

We want to update the data and send out any signals as needed, not just
update the in memory database.
---
 daemons/lvmdbusd/lv.py |    4 ++--
 daemons/lvmdbusd/vg.py |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 79fff87..fa54322 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -618,7 +618,7 @@ class Lv(LvCommon):
 			rc, out, err = cmdhandler.activate_deactivate(
 				'lvchange', lv_name, activate, control_flags, options)
 			if rc == 0:
-				dbo.refresh()
+				cfg.load()
 				return '/'
 			else:
 				raise dbus.exceptions.DBusException(
@@ -667,7 +667,7 @@ class Lv(LvCommon):
 			rc, out, err = cmdhandler.lv_tag(
 				lv_name, tags_add, tags_del, tag_options)
 			if rc == 0:
-				dbo.refresh()
+				cfg.load()
 				return '/'
 			else:
 				raise dbus.exceptions.DBusException(
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index d84bb75..9b1df4e 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -727,7 +727,7 @@ class Vg(AutomatedProperties):
 			rc, out, err = cmdhandler.vg_tag(
 				vg_name, tags_add, tags_del, tag_options)
 			if rc == 0:
-				dbo.refresh()
+				cfg.load()
 				return '/'
 			else:
 				raise dbus.exceptions.DBusException(
@@ -780,7 +780,7 @@ class Vg(AutomatedProperties):
 		if dbo:
 			rc, out, err = method(vg_name, value, options)
 			if rc == 0:
-				dbo.refresh()
+				cfg.load()
 				return '/'
 			else:
 				raise dbus.exceptions.DBusException(


