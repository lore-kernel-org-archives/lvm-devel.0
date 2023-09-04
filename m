From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Mon, 04 Sep 2023 16:52:58 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: tests: check for binaries
Message-ID: <64f60b6a3b1e8_28a3ffc260e1@gitlab-sidekiq-low-urgency-cpu-bound-v2-57cfc4d7d6-fxjkz.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
cc8178e9 by Zdenek Kabelac at 2023-09-04T17:48:41+02:00
tests: check for binaries

vdo wrapper tool uses some &#39;locally installed&#39; binaries
for vdoformat and vdoprepareforlvm
Chech for their presence.

Skip this test with lvmlockd.

- - - - -
2b8b5129 by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
tests: check for writecache

Writecache needs writecache kernel target to be present.

- - - - -
5a441352 by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
tests: disable logging for lvmdbusd

Since lvmdbusd testing tends to do its own logging,
try for now to disable very generic logging mechnanism
of the test suite and see the result.

Some lvmdbusd test seems to rely on some log/file logic
which is modified with the use of these shell vars.

- - - - -
2eb34ede by Zdenek Kabelac at 2023-09-04T18:52:02+02:00
make: generate

- - - - -


4 changed files:

- man/lvconvert.8_pregen
- test/lib/aux.sh
- test/shell/caching-snapshot.sh
- test/shell/vdo-scsi-convert.sh


Changes:

=====================================
man/lvconvert.8_pregen
=====================================
@@ -497,6 +497,9 @@ Convert LV to a thin LV, using the original LV as an external origin.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped thin cache raid error zero
@@ -530,6 +533,9 @@ Convert LV to a thin LV, using LV as thin-pool data volume.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped cache vdo raid error zero writecache
@@ -571,6 +577,9 @@ Attach a cache pool to an LV, converts the LV to type cache.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped thin thinpool vdo vdopool vdopooldata raid error zero
@@ -1769,6 +1778,9 @@ Convert LV to a thin LV, using the original LV as an external origin.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped thin cache raid error zero
@@ -1803,6 +1815,9 @@ Convert LV to a thin LV, using LV as thin-pool data volume.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped cache vdo raid error zero writecache
@@ -1845,6 +1860,9 @@ Attach a cache pool to an LV.
 [ COMMON_OPTIONS ]
 .ad b
 .RE
+.RS 4
+[ \fIPV\fP ... ]
+.RE
 .P
 .RS 4
 LV1 types: linear striped thin thinpool vdo vdopool vdopooldata raid error zero


=====================================
test/lib/aux.sh
=====================================
@@ -274,7 +274,7 @@ prepare_lvmdbusd() {
 
 	kill_sleep_kill_ LOCAL_LVMDBUSD 0
 
-        # FIXME: This is not correct! Daemon is auto started.
+	# FIXME: This is not correct! Daemon is auto started.
 	echo -n "## checking lvmdbusd is NOT running..."
 	if pgrep -f -l lvmdbusd | grep python3 || pgrep -x -l lvmdbusd ; then
 		skip "Cannot run lvmdbusd while existing lvmdbusd process exists"
@@ -314,6 +314,12 @@ prepare_lvmdbusd() {
 	lvmconf "global/notify_dbus = 1"
 
 	test "${LVM_DEBUG_LVMDBUS:-0}" != "0" && lvmdbusdebug="--debug"
+
+	# Currently do not interfere with lvmdbusd testing of the file logging
+	unset LVM_LOG_FILE_EPOCH
+	unset LVM_LOG_FILE_MAX_LINES
+	unset LVM_EXPECTED_EXIT_STATUS
+
 	"$daemon" $lvmdbusdebug > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 


=====================================
test/shell/caching-snapshot.sh
=====================================
@@ -22,6 +22,9 @@ lvm segtypes 2>/dev/null | grep writecache$ >/dev/null || {
 aux have_cache 1 10 0 || skip
 which mkfs.ext4 || skip
 
+HAVE_WRITECACHE=1
+aux have_writecache 1 0 0 || HAVE_WRITECACHE=0
+
 mount_dir="mnt"
 mkdir -p "$mount_dir"
 
@@ -105,7 +108,10 @@ test_snap_remove() {
 
 test_snap_remove cache --cachepool
 test_snap_remove cache --cachevol
+
+if [ "$HAVE_WRITECACHE" = "1" ]; then
 test_snap_remove writecache --cachevol
+fi
 
 # adding cache|writecache to an LV that has a snapshot
 
@@ -143,7 +149,10 @@ test_caching_with_snap() {
 
 test_caching_with_snap cache --cachepool
 test_caching_with_snap cache --cachevol
+
+if [ "$HAVE_WRITECACHE" = "1" ]; then
 test_caching_with_snap writecache --cachevol
+fi
 
 # adding cache|writecache to a snapshot is not allowed
 


=====================================
test/shell/vdo-scsi-convert.sh
=====================================
@@ -12,7 +12,7 @@
 
 # Test conversion of VDO volumes made by vdo manager into VDO LV.
 
-
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -30,6 +30,8 @@ aux have_vdo 6 2 3 || skip
 
 if not which vdo ; then
 	which lvm_vdo_wrapper || skip "Missing 'lvm_vdo_wrapper'."
+	which oldvdoformat || skip "Emulation of vdo manager 'oldvdoformat' missing."
+	which oldvdoprepareforlvm || skip "Emulation of vdo manager 'oldvdoprepareforlvm' missing."
 	# enable expansion of aliasis within script itself
 	shopt -s expand_aliases
 	alias vdo='lvm_vdo_wrapper'



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e9eeb84040aacf5c65b2f8f87b9dc3943da0fcdd...2eb34edeba8ffc9e22b6533e9cb20e0b5e93606b

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e9eeb84040aacf5c65b2f8f87b9dc3943da0fcdd...2eb34edeba8ffc9e22b6533e9cb20e0b5e93606b
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230904/b848979d/attachment-0001.htm>
