From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:36 +0000 (UTC)
Subject: master - lvmdbusd: _lv_create, simplify return path
Message-ID: <20161117173636.46ADF60D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24fd1dd7a3ac3f9692e2a561c8cd10bdd0d32d96
Commit:        24fd1dd7a3ac3f9692e2a561c8cd10bdd0d32d96
Parent:        cd28717f2418559e91e779628bc5ef34b9ad05c9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 10:44:04 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: _lv_create, simplify return path

---
 daemons/lvmdbusd/lv.py |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index fd7aa1e..79fff87 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -738,15 +738,13 @@ class LvThinPool(Lv):
 		# Make sure we have a dbus object representing it
 		dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
 
-		lv_created = '/'
-
 		if dbo:
 			rc, out, err = cmdhandler.lv_lv_create(
 				lv_name, create_options, name, size_bytes)
 			if rc == 0:
 				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
 				cfg.load()
-				lv_created = cfg.om.get_object_path_by_lvm_id(full_name)
+				return cfg.om.get_object_path_by_lvm_id(full_name)
 			else:
 				raise dbus.exceptions.DBusException(
 					LV_INTERFACE,
@@ -756,7 +754,6 @@ class LvThinPool(Lv):
 				LV_INTERFACE,
 				'LV with uuid %s and name %s not present!' %
 				(lv_uuid, lv_name))
-		return lv_created
 
 	@dbus.service.method(
 		dbus_interface=THIN_POOL_INTERFACE,


