From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 22 Jan 2015 18:55:01 +0000 (UTC)
Subject: master - lvmthin: update monitor and autoextend
Message-ID: <20150122185501.1FB4D60223@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b099d06b119013bbf27ffb8a0f056fe725ce603
Commit:        4b099d06b119013bbf27ffb8a0f056fe725ce603
Parent:        0fddc5ab5c892d02fd097828de36ee033dc1e7b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 22 12:52:39 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 22 12:53:25 2015 -0600

lvmthin: update monitor and autoextend

and some more in data exhaustion
---
 man/lvmthin.7.in |  101 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 73 insertions(+), 28 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 908701a..e342a2d 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -673,35 +673,67 @@ space in a thin pool.
 
 \&
 
-An lvm daemon (dmeventd) will by default monitor the data usage of
-thin pool LVs and extend them when the usage reaches a certain level.
-The necessary free space must exist in the VG to extend the thin pool
-LVs.
+The lvm daemon dmeventd (lvm2-monitor) monitors the data usage of thin
+pool LVs and extends them when the usage reaches a certain level.  The
+necessary free space must exist in the VG to extend thin pool LVs.
+Monitoring and extension of thin pool LVs are controlled independently.
 
-Command to enable or disable the monitoring and automatic extension
-of an existing thin pool LV:
+.I monitoring
 
+When a thin pool LV is activated, dmeventd will begin monitoring it by
+default.
+
+Command to start or stop dmeventd monitoring a thin pool LV:
+.br
 .B lvchange \-\-monitor {y|n} VG/ThinPoolLV
 
+The current dmeventd monitoring status of a thin pool LV can be displayed
+with the command lvs -o+seg_monitor.
+
+.I autoextend
+
+dmeventd should be configured to extend thin pool LVs before all data
+space is used.  Warnings are emitted through syslog when the use of a thin
+pool reaches 80%, 85%, 90% and 95%.  (See the section "Data space
+exhaustion" for the effects of not extending a thin pool LV.)  The point
+at which dmeventd extends thin pool LVs, and the amount are controlled
+with two configuration settings:
+
 .BR lvm.conf (5)
 .B thin_pool_autoextend_threshold
 .br
+is a percentage full value that defines when the thin pool LV should be
+extended.  Setting this to 100 disables automatic extention.  The minimum
+value is 50.
+
 .BR lvm.conf (5)
 .B thin_pool_autoextend_percent
 .br
-control the default autoextend behavior.
+defines how much extra data space should be added to the thin pool LV from
+the VG, in percent of its current size.
+
+.I disabling
+
+There are multiple ways that extension of thin pools could be prevented:
+
+.IP \[bu] 2
+If the dmeventd daemon is not running, no monitoring or automatic
+extension will occur.
 
-thin_pool_autoextend_threshold
-is a percentage value that defines when
-the thin pool LV should be extended.  Setting this to 100 disables
-automatic extention.  The minimum value is 50.
+.IP \[bu]
+Even when dmeventd is running, all monitoring can be disabled with the
+lvm.conf monitoring setting.
 
-thin_pool_autoextend_percent
-defines how much extra data space should
-be added to the thin pool, in percent of its current size.
+.IP \[bu]
+To activate or create a thin pool LV without interacting with dmeventd,
+the --ignoremonitoring option can be used.  With this option, the command
+will not ask dmeventd to monitor the thin pool LV.
 
-Warnings are emitted through syslog when the use of a pool reaches 80%,
-85%, 90% and 95%.
+.IP \[bu]
+Setting thin_pool_autoextend_threshould to 100 disables automatic
+extension of thin pool LVs, even if they are being monitored by dmeventd.
+
+.P
 
 .I Example
 .br
@@ -716,22 +748,34 @@ For a 1G pool, using 700M will trigger a resize to 1.2G. When the usage exceeds
 \&
 
 When properly managed, thin pool data space should be extended before it
-is exhausted (see the section "Automatically extend thin pool LV").  If
+is all used (see the section "Automatically extend thin pool LV").  If
 thin pool data space is already exhausted, it can still be extended (see
 the section "Manually manage free data space of thin pool LV".)
 
-The behavior of a full thin pool with no remaining data space is
-configurable with the --errorwhenfull y|n option to lvcreate or lvchange.
-The errorwhenfull setting applies only to writes; reading thin LVs can
-continue even when data space is exhausted.
-
-Command to change the handling of no data space of a thin pool:
+The behavior of a full thin pool is configurable with the --errorwhenfull
+y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
+only to writes; reading thin LVs can continue even when data space is
+exhausted.
 
+Command to change the handling of a full thin pool:
+.br
 .B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
 
-The current setting can be displayed with the lvs -o+lv_when_full command.
+.BR lvm.conf (5)
+.B error_when_full
+.br
+controls the default error when full behavior.
+
+The current setting of a thin pool LV can be displayed with the command:
+lvs -o+lv_when_full.
+
+The errorwhenfull setting does not effect the monitoring and autoextend
+settings, and the monitoring/autoextend settings do not effect the
+errorwhenfull setting.  It is only when monitoring/autoextend are not
+effective that the thin pool becomes full and the errorwhenfull setting is
+applied.
 
-.B errorwhenfull n
+.I errorwhenfull n
 
 This is the default.  Writes to thin LVs are accepted and queued, with the
 expectation that pool data space will be extended soon.  Once data space
@@ -751,13 +795,13 @@ If set to 0, writes will not time out.  Disabling timeouts can result in
 the system running out of resources, memory exhaustion, hung tasks, and
 deadlocks.  (The timeout applies to all thin pools on the system.)
 
-.B errorwhenfull y
+.I errorwhenfull y
 
 Writes to thin LVs immediately return an error, and no writes are queued.
 In the case of a file system, this can result in corruption that may
 require fsck (the specific consequences depend on the thin LV user.)
 
-.B display data percent
+.I data percent
 
 When data space is exhausted, the lvs command displays 100 under Data% for
 the thin pool LV:
@@ -768,7 +812,7 @@ the thin pool LV:
   pool0  vg           twi-a-tz-- 512.00m              100.00
 .fi
 
-.B causes
+.I causes
 
 A thin pool may run out of data space for any of the following reasons:
 
@@ -788,6 +832,7 @@ thin_pool_autoextend_threshold and thin_pool_autoextend_percent.)
 .IP \[bu]
 The VG does not have enough free blocks to extend the thin pool.
 
+.P
 
 .SS Metadata space exhaustion
 


