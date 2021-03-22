From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:08 +0000 (GMT)
Subject: dev-next - man: lvmlockd use of lvmlockctl_kill_command
Message-ID: <20210322153908.378E8385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a481fdaa3529a85e0cde652f79b98b2337c296cb
Commit:        a481fdaa3529a85e0cde652f79b98b2337c296cb
Parent:        583cf413d530927bccf2b7a11f3d5690edca4f8d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 17 13:00:47 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 17 13:02:51 2021 -0500

man: lvmlockd use of lvmlockctl_kill_command

---
 man/lvmlockd.8_main | 89 ++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 65 insertions(+), 24 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index f4c504d70..d1eee63fc 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -576,32 +576,73 @@ If the PV under a sanlock VG's lvmlock LV is disconnected, unresponsive or
 too slow, sanlock cannot renew the lease for the VG's locks.  After some
 time, the lease will expire, and locks that the host owns in the VG can be
 acquired by other hosts.  The VG must be forcibly deactivated on the host
-with the expiring lease before other hosts can acquire its locks.
+with the expiring lease before other hosts can acquire its locks.  This is
+necessary for data protection.
+
+When the sanlock daemon detects that VG storage is lost and the VG lease
+is expiring, it runs the command lvmlockctl --kill <vgname>.  This command
+emits a syslog message stating that storage is lost for the VG, and that
+LVs in the VG must be immediately deactivated.
+
+If no LVs are active in the VG, then the VG lockspace will be removed, and
+errors will be reported when trying to use the VG.  Use the lvmlockctl
+--drop command to clear the stale lockspace from lvmlockd.
+
+If the VG has active LVs, they must be quickly deactivated before the
+locks expire.  After all LVs are deactivated, run lvmlockctl --drop
+<vgname> to clear the expiring lockspace from lvmlockd.
+
+If all LVs in the VG are not deactivated within about 40 seconds, sanlock
+uses wdmd and the local watchdog to reset the host.  The machine reset is
+effectively a severe form of "deactivating" LVs before they can be
+activated on other hosts.  The reset is considered a better alternative
+than having LVs used by multiple hosts at once, which could easily damage
+or destroy their content.
+
+.B sanlock lease storage failure automation
 
 When the sanlock daemon detects that the lease storage is lost, it runs
-the command lvmlockctl --kill <vgname>.  This command emits a syslog
-message stating that lease storage is lost for the VG, and LVs must be
-immediately deactivated.
-
-If no LVs are active in the VG, then the lockspace with an expiring lease
-will be removed, and errors will be reported when trying to use the VG.
-Use the lvmlockctl --drop command to clear the stale lockspace from
-lvmlockd.
-
-If the VG has active LVs when the lock storage is lost, the LVs must be
-quickly deactivated before the lockspace lease expires.  After all LVs are
-deactivated, run lvmlockctl --drop <vgname> to clear the expiring
-lockspace from lvmlockd.  If all LVs in the VG are not deactivated within
-about 40 seconds, sanlock uses wdmd and the local watchdog to reset the
-host.  The machine reset is effectively a severe form of "deactivating"
-LVs before they can be activated on other hosts.  The reset is considered
-a better alternative than having LVs used by multiple hosts at once, which
-could easily damage or destroy their content.
-
-In the future, the lvmlockctl kill command may automatically attempt to
-forcibly deactivate LVs before the sanlock lease expires.  Until then, the
-user must notice the syslog message and manually deactivate the VG before
-sanlock resets the machine.
+the command lvmlockctl --kill <vgname>.  This lvmlockctl command can be
+configured to run another command to forcibly deactivate LVs, taking the
+place of the manual process described above.  The other command is
+configured in the lvm.conf lvmlockctl_kill_command setting.  The VG name
+is appended to the end of the command specified.
+
+The lvmlockctl_kill_command should forcibly deactivate LVs in the VG,
+ensuring that existing writes to LVs in the VG are complete and that
+further writes to the LVs in the VG will be rejected.  If it is able to do
+this successfully, it should exit with success, otherwise it should exit
+with an error.  If lvmlockctl --kill gets a successful result from
+lvmlockctl_kill_command, it tells lvmlockd to drop locks for the VG (the
+equivalent of running lvmlockctl --drop).  If this completes in time, a
+machine reset can be avoided.
+
+One possible option is to create a script my_vg_kill_script.sh:
+.nf
+  #!/bin/bash
+  VG=$1
+  # replace dm table with the error target for top level LVs
+  dmsetup wipe_table -S "uuid=~LVM && vgname=$VG && lv_layer=\\"\\""
+  # check that the error target is in place
+  dmsetup table -c -S "uuid=~LVM && vgname=$VG && lv_layer=\\"\\"" |grep -vw error
+  if [[ $? -ne 0 ]] ; then
+    exit 0
+  fi
+  exit 1
+.fi
+
+Set in lvm.conf:
+.nf
+  lvmlockctl_kill_command="/usr/sbin/my_vg_kill_script.sh"
+.fi
+
+(The script and dmsetup commands should be tested with the actual VG to
+ensure that all top level LVs are properly disabled.)
+
+If the lvmlockctl_kill_command is not configured, or fails, lvmlockctl
+--kill will emit syslog messages as described in the previous section,
+notifying the user to manually deactivate the VG before sanlock resets the
+machine.
 
 .B sanlock daemon failure
 


