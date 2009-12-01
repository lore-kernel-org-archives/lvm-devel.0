From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 01 Dec 2009 15:11:49 +0100
Subject: [PATCH] Disable udev rules on change event with DISK_RO=1
Message-ID: <4B152425.4090506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There's a new change udev event generated since kernel 2.6.32 that
notifies userspace about a change in read-only attribute for block
devices (with DISK_RO=1 environment variable set):

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e3264a4d7de147677f1995f119eba05c9abe9c1c

We need to detect this and disable the rule application so the
meaning of this change event is not interchanged with the regular
change event used while resuming/renaming DM devices.

If there's anybody awaiting this notification in foreign rules,
he can still check for this env var and do the appropriate actions
separately.

Peter

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index aba0bf4..7cffc0b 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -19,6 +19,13 @@ KERNEL=="device-mapper", NAME="(DM_DIR)/control"
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 
+# There is a new change event generated in block layer since kernel
+# version 2.6.32. It adds notification for changes in read-only
+# attribute. We don't want to misinterpret the regular meaning of change
+# events for DM devices and we don't want to apply the rules prematurely,
+# therefore we disable them in this situation.
+ENV{DISK_RO}=="1", GOTO="dm_disable"
+
 # Set proper sbin path, /sbin has higher priority than /usr/sbin.
 ENV{DM_SBIN_PATH}="/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"


