From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:57 +0000 (GMT)
Subject: main - tests: lvmdbus testing use --debug optinally now
Message-ID: <20230216231057.E12BB3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1788b4b3aa129b9bfbb977be263455680b6dc128
Commit:        1788b4b3aa129b9bfbb977be263455680b6dc128
Parent:        06c5c29443fdd48730a282a5db16e46c793db27b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 16:50:07 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:08:50 2023 +0100

tests: lvmdbus testing use --debug optinally now

To shorten down logging output of lvmdbus - use for now lvmdbus
with --debug option only when LVM_DEBUG_LVMDBUS=1 is set.
---
 test/Makefile.in | 3 ++-
 test/lib/aux.sh  | 4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 1cad634b8..1ea797d85 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -111,12 +111,13 @@ help:
 	@echo "  LVM_TEST_CACHE_REPAIR_CMD  Command for cache_repair  [$(LVM_TEST_CACHE_REPAIR_CMD)]."
 	@echo "  LVM_TEST_CACHE_RESTORE_CMD Command for cache_restore [$(LVM_TEST_CACHE_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
-	@echo "  LVM_TEST_DEVICE_LIST   File path listing real devs that tests can use."
+	@echo "  LVM_TEST_DEVICE_LIST	File path listing real devs that tests can use."
 	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMPOLLD	Enable valgrind testing of lvmpolld (1)."
 	@echo "  LVM_STRACE		Enable strace logging."
 	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
+	@echo "  LVM_DEBUG_LVMDBUS	Run lvmdbus with --debug option."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  LVM_LOG_FILE_MAX_LINES	Maximum number of logged lines for lvm2 command [1000000]."
 	@echo "  S			Skip given test(s) (regex)."
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ccc787eca..c15fd5baa 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -281,6 +281,7 @@ lvmpolld_dump() {
 }
 
 prepare_lvmdbusd() {
+	local lvmdbusdebug=
 	local daemon
 	rm -f debug.log_LVMDBUSD_out
 
@@ -324,7 +325,8 @@ prepare_lvmdbusd() {
 	echo "## preparing lvmdbusd..."
 	lvmconf "global/notify_dbus = 1"
 
-	"$daemon" --debug  > debug.log_LVMDBUSD_out 2>&1 &
+	test "${LVM_DEBUG_LVMDBUS:-0}" != "0" && lvmdbusdebug="--debug"
+	"$daemon" $lvmdbusdebug > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 
 	sleep 1

