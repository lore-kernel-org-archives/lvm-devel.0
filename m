From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Jan 2014 15:02:30 +0000 (UTC)
Subject: master - lvmetad: respect LVM_LVMETAD_PIDFILE settings in lvm
Message-ID: <20140124150230.DCD7A6108B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f18ee04fab76a3d817e7be9da76a589700878830
Commit:        f18ee04fab76a3d817e7be9da76a589700878830
Parent:        89d77326170d020ebba6ae1c717c08ac4b07996a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 24 15:59:38 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 24 15:59:38 2014 +0100

lvmetad: respect LVM_LVMETAD_PIDFILE settings in lvm

Test LVM_LVMETAD_PIDFILE for pid for lvm command.
Fix WHATS_NEW envvar name usage
Fix init order in prepare_lvmetad to respect set vars
and avoid clash with system settings.
Update test to really test the 'is running' message.
---
 WHATS_NEW                      |    3 ++-
 lib/cache/lvmetad.c            |    2 +-
 man/lvm.8.in                   |    6 ++++++
 test/lib/test.sh               |    2 +-
 test/shell/lvmetad-disabled.sh |   13 ++++++++-----
 5 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6818026..d674161 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Respect LVM_LVMETAD_PIDFILE env var for lvm command.
   Avoid exposing temporary devices when initializing thin pool volume.
   Fix test when checking target version for available thin features.
   Detect thin feature external_origin_extend and limit extend when missing.
@@ -41,7 +42,7 @@ Version 2.02.105 - 20th January 2014
   Add --splitsnapshot to lvconvert to separate out cow LV.
   Reinstate origin reload to complete lvconvert -s with active LVs. (2.02.98)
   Select only active volume groups if vgdisplay -A is used.
-  Add -p and LVM_LVMETAD_PID env var to lvmetad to change pid file.
+  Add -p and LVM_LVMETAD_PIDFILE env var to lvmetad to change pid file.
   Allow lvmetad to reuse stale socket.
   Only unlink lvmetad socket on error if created by the same process.
   Append missing newline to lvmetad missing socket path error message.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index aec6a71..61361ed 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -40,7 +40,7 @@ void lvmetad_disconnect(void)
 
 void lvmetad_init(struct cmd_context *cmd)
 {
-	if (!_lvmetad_use && !access(LVMETAD_PIDFILE, F_OK))
+	if (!_lvmetad_use && !access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK))
 		log_warn("WARNING: lvmetad is running but disabled."
 			 " Restart lvmetad before enabling it!");
 	_lvmetad_cmd = cmd;
diff --git a/man/lvm.8.in b/man/lvm.8.in
index d78281a..c377b35 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -301,6 +301,12 @@ is executed.
 The Volume Group name that is assumed for
 any reference to a Logical Volume that doesn't specify a path.
 Not set by default.
+.TP
+.B LVM_LVMETAD_PIDFILE
+Path for the lvmetad pid file.
+.TP
+.B LVM_LVMETAD_SOCKET
+Path for the lvmetad socket file.
 .SH VALID NAMES
 The following characters are valid for VG and LV names:
 .B a-z A-Z 0-9 + _ . -
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 265d61d..71ad55d 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -81,9 +81,9 @@ test -n "$BASH" && set -eE -o pipefail
 aux lvmconf
 aux prepare_clvmd
 test -n "$LVM_TEST_LVMETAD" && {
-	aux prepare_lvmetad
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
+	aux prepare_lvmetad
 }
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 41a3a19..c344d7f 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -13,14 +13,17 @@
 
 test -e LOCAL_LVMETAD || skip
 kill $(cat LOCAL_LVMETAD)
+while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
+test ! -e "$LVM_LVMETAD_PIDFILE"
 
-test -e $LVMETAD_PIDFILE && skip
 lvmetad
-test -e $LVMETAD_PIDFILE
-cp $LVMETAD_PIDFILE LOCAL_LVMETAD
+while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
+test -e "$LVM_LVMETAD_PIDFILE"
+cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
+
 pvs 2>&1 | not grep "lvmetad is running"
 aux lvmconf "global/use_lvmetad = 0"
 pvs 2>&1 | grep "lvmetad is running"
 
-kill $(cat $LVMETAD_PIDFILE)
-not ls $LVMETAD_PIDFILE
+kill $(cat "$LVM_LVMETAD_PIDFILE")
+not ls "$LVM_LVMETAD_PIDFILE"


