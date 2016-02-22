From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:59:57 +0000 (UTC)
Subject: master - tests: skip thin-flags test on 32bit el6 kernel
Message-ID: <20160222135957.2F24760D7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed5e5c38b5ac4b7c8cb7e809d9d35c72f087e29e
Commit:        ed5e5c38b5ac4b7c8cb7e809d9d35c72f087e29e
Parent:        3178cfc81823589cde16668b90a04a35fe0b758b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 14:52:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:59:28 2016 +0100

tests: skip thin-flags test on 32bit el6 kernel

Until kernel is fixed, stop running test always hitting OOPS there.
---
 test/lib/aux.sh          |   12 ++++++++++++
 test/shell/thin-flags.sh |    1 +
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6250143..12316aa 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1007,6 +1007,18 @@ raid456_replace_works() {
 	esac
 }
 
+#
+# Some 32bit kernel cannot pass some erroring magic which forces
+# thin-pool to be falling into Error state.
+#
+# Skip test on such kernels (see: https://bugzilla.redhat.com/1310661)
+#
+thin_pool_error_works_32() {
+	case "$(uname -r)" in
+	  2.6.32-618.*.i686) return 1 ;;
+	esac
+}
+
 udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm &>/dev/null || return 0
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 7dd0d6e..95eafa0 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -39,6 +39,7 @@ fake_metadata_() {
 # Main
 #
 aux have_thin 1 3 0 || skip
+aux thin_pool_error_works_32 || skip
 
 aux prepare_vg 2 256
 


