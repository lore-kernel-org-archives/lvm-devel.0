From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 17 Oct 2023 16:06:58 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: make: generate
Message-ID: <652eb12235b70_2c2a5229010f1@gitlab-sidekiq-low-urgency-cpu-bound-v2-b745b49f7-kbq57.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
7e017abb by Zdenek Kabelac at 2023-10-17T16:48:50+02:00
make: generate

- - - - -
493af2bb by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
lvm: fix reporting path with HOME envvar

When envvar HOME is not present we were using invalid path with (null).

- - - - -
cb2873ba by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
tests: ensure file is removed

Make sure there are no previous loop results.

- - - - -
249446e0 by Zdenek Kabelac at 2023-10-17T16:49:23+02:00
tests: avoid busy looping

While waiting for the change, don&#39;t busy loop on CPU.
TODO: fix missing notification about device removal.

- - - - -


4 changed files:

- man/lvmdevices.8_pregen
- test/dbus/lvmdbustest.py
- test/shell/dmsecuretest.sh
- tools/lvm.c


Changes:

=====================================
man/lvmdevices.8_pregen
=====================================
@@ -177,6 +177,12 @@ The default choice for device ID type can be overridden using lvmdevices
 device it will be used, otherwise the device will be added using the type
 that would otherwise be chosen.
 
+LVM commands run by dmeventd will use the devices file
+\fI#DEFAULT_SYS_DIR#/devices/dmeventd.devices\fP if it exists,
+otherwise system.devices is used.  VGs that require the dmeventd
+service should be included in system.devices, even if they are
+included in dmeventd.devices.
+
 .SS Device ID refresh
 .P
 A machine identifier is saved in the devices file, and is used to detect


=====================================
test/dbus/lvmdbustest.py
=====================================
@@ -2416,8 +2416,9 @@ class TestDbusService(unittest.TestCase):
 	def _block_present_absent(self, block_device, present=False):
 		start = time.time()
 		keep_looping = True
-		max_wait = 10
+		max_wait = 5
 		while keep_looping and time.time() < start + max_wait:
+			time.sleep(0.2)
 			if present:
 				if (self._lookup(block_device) != "/"):
 					keep_looping = False


=====================================
test/shell/dmsecuretest.sh
=====================================
@@ -38,6 +38,7 @@ for i in securetest dmsecuretest ; do
 # 2nd. retry with already exiting DM node - exercize error path also wipes
 for j in empty existing ; do
 
+rm -f cmdout
 "$i" "$dev1" "$DMTEST" >cmdout 2>&1 &
 PID=$!
 for k in $(seq 1 10); do


=====================================
tools/lvm.c
=====================================
@@ -154,7 +154,7 @@ static int _hist_file(char *buffer, size_t size)
 {
 	char *e = getenv("HOME");
 
-	if (dm_snprintf(buffer, size, "%s/.lvm_history", e) < 0) {
+	if (dm_snprintf(buffer, size, "%s%s.lvm_history", e ? :"", e ? "/" : "") < 0) {
 		log_error("$HOME/.lvm_history: path too long");
 		return 0;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/be9a64e6542eea544bcaf122e61183f2c3aad682...249446e0aa0a3b5f80dfa0879839cffe20479f61

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/be9a64e6542eea544bcaf122e61183f2c3aad682...249446e0aa0a3b5f80dfa0879839cffe20479f61
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231017/ca221912/attachment-0001.htm>
