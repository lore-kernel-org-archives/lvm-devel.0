From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 26 Apr 2017 09:36:26 -0400
Subject: master - lvmdbusd: Make sure we don't hang on lvcreate
Message-ID: <201704261336.v3QDaQPe008710@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e78329e281db780cc4a9acce20b0f58dc9221fab
Commit:        e78329e281db780cc4a9acce20b0f58dc9221fab
Parent:        a3fdc966b51336fa7b77a26890539c26a0427199
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Apr 22 00:03:46 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Apr 26 07:10:18 2017 -0500

lvmdbusd: Make sure we don't hang on lvcreate

If we happen to create a lv that has a previous signature we hang on y/n
prompt, add '--yes'.
---
 daemons/lvmdbusd/cmdhandler.py |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index cbf6036..94c3f59 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -279,7 +279,7 @@ def vg_lv_create(vg_name, create_options, name, size_bytes, pv_dests):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
 	cmd.extend(['--size', str(size_bytes) + 'B'])
-	cmd.extend(['--name', name, vg_name])
+	cmd.extend(['--name', name, vg_name, '--yes'])
 	pv_dest_ranges(cmd, pv_dests)
 	return call(cmd)
 
@@ -304,6 +304,8 @@ def _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool):
 		cmd.extend(['--size', str(size_bytes) + 'B'])
 	else:
 		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
+
+	cmd.extend(['--yes'])
 	return cmd
 
 
@@ -340,7 +342,7 @@ def _vg_lv_create_raid(vg_name, create_options, name, raid_type, size_bytes,
 	if stripe_size_kb != 0:
 		cmd.extend(['--stripesize', str(stripe_size_kb)])
 
-	cmd.extend(['--name', name, vg_name])
+	cmd.extend(['--name', name, vg_name, '--yes'])
 	return call(cmd)
 
 
@@ -361,7 +363,7 @@ def vg_lv_create_mirror(
 	cmd.extend(['--type', 'mirror'])
 	cmd.extend(['--mirrors', str(num_copies)])
 	cmd.extend(['--size', str(size_bytes) + 'B'])
-	cmd.extend(['--name', name, vg_name])
+	cmd.extend(['--name', name, vg_name, '--yes'])
 	return call(cmd)
 
 
@@ -415,7 +417,7 @@ def lv_lv_create(lv_full_name, create_options, name, size_bytes):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
 	cmd.extend(['--virtualsize', str(size_bytes) + 'B', '-T'])
-	cmd.extend(['--name', name, lv_full_name])
+	cmd.extend(['--name', name, lv_full_name, '--yes'])
 	return call(cmd)
 
 


