From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:33:02 -0500
Subject: master - lvmdbusd: Use UUID instead of name for VG rename
Message-ID: <201901162233.x0GMX2IS027546@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d142f65141d591430ced6a7a7fcccb4d2198d28
Commit:        0d142f65141d591430ced6a7a7fcccb4d2198d28
Parent:        f43b7bb46159d00a4eba56df92ad5e572fa2038c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Jan 16 15:43:39 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd:  Use UUID instead of name for VG rename

Use the UUID to specify the VG to rename instead of the name as this
approach works when we have duplicate VG names.
---
 daemons/lvmdbusd/cmdhandler.py |    4 ++--
 daemons/lvmdbusd/vg.py         |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index fde7f5e..df854eb 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -263,10 +263,10 @@ def lv_tag(lv_name, add, rm, tag_options):
 	return _tag('lvchange', lv_name, add, rm, tag_options)
 
 
-def vg_rename(vg, new_name, rename_options):
+def vg_rename(vg_uuid, new_name, rename_options):
 	cmd = ['vgrename']
 	cmd.extend(options_to_cli_args(rename_options))
-	cmd.extend([vg, new_name])
+	cmd.extend([vg_uuid, new_name])
 	return call(cmd)
 
 
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 64ad0f0..7011ff8 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -177,7 +177,7 @@ class Vg(AutomatedProperties):
 		# Make sure we have a dbus object representing it
 		Vg.validate_dbus_object(uuid, vg_name)
 		rc, out, err = cmdhandler.vg_rename(
-			vg_name, new_name, rename_options)
+			uuid, new_name, rename_options)
 		Vg.handle_execute(rc, out, err)
 		return '/'
 


