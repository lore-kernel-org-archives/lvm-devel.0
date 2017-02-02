From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:29 +0000 (UTC)
Subject: master - lvmdbusd: cmdhandler.py, remove duplicate code
Message-ID: <20170202165929.2596D6024A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=875ce04c61fb40436bf4d6308356c800d08c1f7e
Commit:        875ce04c61fb40436bf4d6308356c800d08c1f7e
Parent:        3eccbb4b4713f0d79831e7c146851bff820c94bb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 19:05:41 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 19:05:41 2017 -0600

lvmdbusd: cmdhandler.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/cmdhandler.py |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index f1591aa..31b7c5c 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -295,7 +295,7 @@ def vg_lv_snapshot(vg_name, snapshot_options, name, size_bytes):
 	return call(cmd)
 
 
-def vg_lv_create_linear(vg_name, create_options, name, size_bytes, thin_pool):
+def _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
 
@@ -303,20 +303,18 @@ def vg_lv_create_linear(vg_name, create_options, name, size_bytes, thin_pool):
 		cmd.extend(['--size', str(size_bytes) + 'B'])
 	else:
 		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
+	return cmd
+
+
+def vg_lv_create_linear(vg_name, create_options, name, size_bytes, thin_pool):
+	cmd = _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool)
 	cmd.extend(['--name', name, vg_name])
 	return call(cmd)
 
 
 def vg_lv_create_striped(vg_name, create_options, name, size_bytes,
 							num_stripes, stripe_size_kb, thin_pool):
-	cmd = ['lvcreate']
-	cmd.extend(options_to_cli_args(create_options))
-
-	if not thin_pool:
-		cmd.extend(['--size', str(size_bytes) + 'B'])
-	else:
-		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
-
+	cmd = _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool)
 	cmd.extend(['--stripes', str(num_stripes)])
 
 	if stripe_size_kb != 0:


