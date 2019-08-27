From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 27 Aug 2019 10:44:16 -0400
Subject: master - Fix converting dbus.UInt types to string
Message-ID: <201908271444.x7REiG8d025823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32a8865a272d31d5bc12332a4da0309ce3af9243
Commit:        32a8865a272d31d5bc12332a4da0309ce3af9243
Parent:        b2885b7103049b11ca3e98fe0c8898df2ce5f9ac
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Mon Aug 26 14:35:51 2019 +0200
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Aug 27 09:43:43 2019 -0500

Fix converting dbus.UInt types to string

With Python 3.8 converting these directly to string using str()
no longer works, we need to convert these to integer first.

On Python 3.8:

>>> str(dbus.Int64(1))
'dbus.Int64(1)'

On Python 3.7 (and older):
>>> str(dbus.UInt64(1))
'1'

This is probably related to removing __str__ function from method
from int (dbus.UInt is subclass of int) which happened in 3.8, see
https://docs.python.org/3.8/whatsnew/3.8.html

Signed-off-by: Vojtech Trefny <vtrefny@redhat.com>
---
 daemons/lvmdbusd/cmdhandler.py |   35 +++++++++++++++++++----------------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index df854eb..f7f6acd 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -217,7 +217,10 @@ def options_to_cli_args(options):
 		else:
 			rc.append("--%s" % k)
 		if v != "":
-			rc.append(str(v))
+			if isinstance(v, int):
+				rc.append(str(int(v)))
+			else:
+				rc.append(str(v))
 	return rc
 
 
@@ -280,7 +283,7 @@ def vg_remove(vg_name, remove_options):
 def vg_lv_create(vg_name, create_options, name, size_bytes, pv_dests):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
-	cmd.extend(['--size', str(size_bytes) + 'B'])
+	cmd.extend(['--size', '%dB' % size_bytes])
 	cmd.extend(['--name', name, vg_name, '--yes'])
 	pv_dest_ranges(cmd, pv_dests)
 	return call(cmd)
@@ -292,7 +295,7 @@ def vg_lv_snapshot(vg_name, snapshot_options, name, size_bytes):
 	cmd.extend(["-s"])
 
 	if size_bytes != 0:
-		cmd.extend(['--size', str(size_bytes) + 'B'])
+		cmd.extend(['--size', '%dB' % size_bytes])
 
 	cmd.extend(['--name', name, vg_name])
 	return call(cmd)
@@ -303,9 +306,9 @@ def _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool):
 	cmd.extend(options_to_cli_args(create_options))
 
 	if not thin_pool:
-		cmd.extend(['--size', str(size_bytes) + 'B'])
+		cmd.extend(['--size', '%dB' % size_bytes])
 	else:
-		cmd.extend(['--thin', '--size', str(size_bytes) + 'B'])
+		cmd.extend(['--thin', '--size', '%dB' % size_bytes])
 
 	cmd.extend(['--yes'])
 	return cmd
@@ -320,10 +323,10 @@ def vg_lv_create_linear(vg_name, create_options, name, size_bytes, thin_pool):
 def vg_lv_create_striped(vg_name, create_options, name, size_bytes,
 							num_stripes, stripe_size_kb, thin_pool):
 	cmd = _vg_lv_create_common_cmd(create_options, size_bytes, thin_pool)
-	cmd.extend(['--stripes', str(num_stripes)])
+	cmd.extend(['--stripes', str(int(num_stripes))])
 
 	if stripe_size_kb != 0:
-		cmd.extend(['--stripesize', str(stripe_size_kb)])
+		cmd.extend(['--stripesize', str(int(stripe_size_kb))])
 
 	cmd.extend(['--name', name, vg_name])
 	return call(cmd)
@@ -336,13 +339,13 @@ def _vg_lv_create_raid(vg_name, create_options, name, raid_type, size_bytes,
 	cmd.extend(options_to_cli_args(create_options))
 
 	cmd.extend(['--type', raid_type])
-	cmd.extend(['--size', str(size_bytes) + 'B'])
+	cmd.extend(['--size', '%dB' % size_bytes])
 
 	if num_stripes != 0:
-		cmd.extend(['--stripes', str(num_stripes)])
+		cmd.extend(['--stripes', str(int(num_stripes))])
 
 	if stripe_size_kb != 0:
-		cmd.extend(['--stripesize', str(stripe_size_kb)])
+		cmd.extend(['--stripesize', str(int(stripe_size_kb))])
 
 	cmd.extend(['--name', name, vg_name, '--yes'])
 	return call(cmd)
@@ -363,8 +366,8 @@ def vg_lv_create_mirror(
 	cmd.extend(options_to_cli_args(create_options))
 
 	cmd.extend(['--type', 'mirror'])
-	cmd.extend(['--mirrors', str(num_copies)])
-	cmd.extend(['--size', str(size_bytes) + 'B'])
+	cmd.extend(['--mirrors', str(int(num_copies))])
+	cmd.extend(['--size', '%dB' % size_bytes])
 	cmd.extend(['--name', name, vg_name, '--yes'])
 	return call(cmd)
 
@@ -418,7 +421,7 @@ def lv_resize(lv_full_name, size_change, pv_dests,
 def lv_lv_create(lv_full_name, create_options, name, size_bytes):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
-	cmd.extend(['--virtualsize', str(size_bytes) + 'B', '-T'])
+	cmd.extend(['--virtualsize', '%dB' % size_bytes, '-T'])
 	cmd.extend(['--name', name, lv_full_name, '--yes'])
 	return call(cmd)
 
@@ -556,7 +559,7 @@ def pv_resize(device, size_bytes, create_options):
 	cmd.extend(options_to_cli_args(create_options))
 
 	if size_bytes != 0:
-		cmd.extend(['--yes', '--setphysicalvolumesize', str(size_bytes) + 'B'])
+		cmd.extend(['--yes', '--setphysicalvolumesize', '%dB' % size_bytes])
 
 	cmd.extend([device])
 	return call(cmd)
@@ -652,12 +655,12 @@ def vg_allocation_policy(vg_name, policy, policy_options):
 
 
 def vg_max_pv(vg_name, number, max_options):
-	return _vg_value_set(vg_name, ['--maxphysicalvolumes', str(number)],
+	return _vg_value_set(vg_name, ['--maxphysicalvolumes', str(int(number))],
 							max_options)
 
 
 def vg_max_lv(vg_name, number, max_options):
-	return _vg_value_set(vg_name, ['-l', str(number)], max_options)
+	return _vg_value_set(vg_name, ['-l', str(int(number))], max_options)
 
 
 def vg_uuid_gen(vg_name, ignore, options):


