From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Sun, 15 Oct 2023 22:23:52 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: tests: fsck with yes
Message-ID: <652c66789fee2_2ca54106183a@gitlab-sidekiq-low-urgency-cpu-bound-v2-59d68cd46b-h46pq.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
dfaa8912 by Zdenek Kabelac at 2023-10-15T19:51:43+02:00
tests: fsck with yes

Fsck may need to update metadata even after clean unmount.

- - - - -
098bc780 by Zdenek Kabelac at 2023-10-15T21:48:22+02:00
tests: better synchronization

- - - - -
f55dc300 by Zdenek Kabelac at 2023-10-15T21:48:22+02:00
tests: simplify line counting

No need for pipes

- - - - -
d12e843e by Zdenek Kabelac at 2023-10-16T00:11:35+02:00
tests: aux mdadm_assemble skip path

If the old mdadm fails to assembly array due to its internal buggy logic
skip the test instead of failure.

- - - - -


7 changed files:

- test/lib/aux.sh
- test/lib/dmsecuretest.c
- test/shell/devicesfile-realdevs.sh
- test/shell/dmsecuretest.sh
- test/shell/lvresize-fs-crypt.sh
- test/shell/select-report.sh
- test/shell/udev-pvscan-vgchange.sh


Changes:

=====================================
test/lib/aux.sh
=====================================
@@ -829,7 +829,7 @@ mdadm_assemble() {
 		STRACE="strace -f -o /dev/null"
 	}
 
-	$STRACE mdadm --assemble "$@"
+	$STRACE mdadm --assemble "$@" || { test -n "$STRACE" && skip "Timing failure" ; false ; }
 	udev_wait
 }
 


=====================================
test/lib/dmsecuretest.c
=====================================
@@ -73,8 +73,10 @@ int main (int argc, char *argv[])
 		(void) dm_task_run(dmt);
 		(void) dm_task_destroy(dmt);
 		(void) dm_udev_wait(cookie); /* Finish udev processing */
+		printf("Created device: %s\n", devname);
 	}
 
+	fflush(stdout);
 	/* At this point there should be no memory trace from a secure table line */
 
 #ifdef SLEEP


=====================================
test/shell/devicesfile-realdevs.sh
=====================================
@@ -34,7 +34,7 @@ if [ -z ${LVM_TEST_DEVICE_LIST+x} ]; then echo "LVM_TEST_DEVICE_LIST is unset" &
 
 test -e "$LVM_TEST_DEVICE_LIST" || skip
 
-num_devs=$(cat $LVM_TEST_DEVICE_LIST | wc -l)
+num_devs=$(wc -l < "$LVM_TEST_DEVICE_LIST")
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"


=====================================
test/shell/dmsecuretest.sh
=====================================
@@ -40,7 +40,11 @@ for j in empty existing ; do
 
 "$i" "$dev1" "$DMTEST" >cmdout 2>&1 &
 PID=$!
-sleep .6
+for k in $(seq 1 10); do
+	lines=$(wc -l < cmdout 2>/dev/null || true)
+	test "${lines:-0}" = "0" || break
+	sleep .1
+done
 
 # 0 8192 crypt aes-xts-plain64 434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122 0 253:0 8192
 # crypt device should be loaded
@@ -50,7 +54,7 @@ dmsetup status "$DMTEST"
 gcore "$PID" | tee out || skip
 
 # check we capture core while  dmsecuretest was already sleeping
-grep "nanosleep" out || grep kernel_vsyscall out
+grep -e "nanosleep\|kernel_vsyscall" out
 kill "$PID" || true
 wait
 


=====================================
test/shell/lvresize-fs-crypt.sh
=====================================
@@ -141,7 +141,7 @@ dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=10 oflag=direct
 df --output=size "$mount_dir" |tee df1
 # resize only the fs (to 256M), not the crypt dev or LV
 umount "$mount_dir"
-fsck -fn /dev/mapper/$cr
+fsck -fy /dev/mapper/$cr
 resize2fs /dev/mapper/$cr 262144k
 mount /dev/mapper/$cr "$mount_dir"
 # this lvresize will not resize the fs (which is already reduced


=====================================
test/shell/select-report.sh
=====================================
@@ -59,7 +59,7 @@ sel() {
 		return 1
 	}
 
-	items_found=$(wc -l "$OUT_LOG_FILE" | cut -f 1 -d ' ')
+	items_found=$(wc -l < "$OUT_LOG_FILE")
 
 	# the number of lines on output must match
 	test "$items_found" -eq $# || {


=====================================
test/shell/udev-pvscan-vgchange.sh
=====================================
@@ -40,7 +40,7 @@ fi
 
 test -e "$LVM_TEST_DEVICE_LIST" || skip
 
-num_devs=$(cat "$LVM_TEST_DEVICE_LIST" | wc -l)
+num_devs=$(wc -l < "$LVM_TEST_DEVICE_LIST")
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/d5e58768aaa6312124d344e3c44ada9eacf94811...d12e843e4a23da03ddfd791c4660c6909d07026c

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/d5e58768aaa6312124d344e3c44ada9eacf94811...d12e843e4a23da03ddfd791c4660c6909d07026c
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231015/5531ac06/attachment-0001.htm>
