From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Nov 2017 11:38:32 -0500
Subject: master - man: lvmlockd steps for changing lock type
Message-ID: <201711211638.vALGcWjl025008@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea0463791dcc68082ecf0b6b6681e82becaffb40
Commit:        ea0463791dcc68082ecf0b6b6681e82becaffb40
Parent:        bbaaf4f1d34a1a097c20dca1f36a0f6a50c5d066
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 21 10:37:00 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 21 10:37:00 2017 -0600

man: lvmlockd steps for changing lock type

were not quite correct
---
 man/lvmlockd.8_main |   45 +++++++++++++++++++++++++++++++++++++--------
 1 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index b7eba1a..fbcdc87 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -706,19 +706,24 @@ To change the dlm cluster name in the VG when the VG is still used by the
 original cluster:
 
 .IP \[bu] 2
-Stop the VG on all hosts:
+Start the VG on the host changing the lock type
+.br
+vgchange --lock-start <vgname>
+
+.IP \[bu] 2
+Stop the VG on all other hosts:
 .br
 vgchange --lock-stop <vgname>
 
 .IP \[bu] 2
-Change the VG lock type to none:
+Change the VG lock type to none on the host where the VG is started:
 .br
 vgchange --lock-type none <vgname>
 
 .IP \[bu] 2
-Change the dlm cluster name on the host or move the VG to the new cluster.
-The new dlm cluster must now be active on the host.  Verify the new name
-by:
+Change the dlm cluster name on the hosts or move the VG to the new
+cluster.  The new dlm cluster must now be running on the host.  Verify the
+new name by:
 .br
 cat /sys/kernel/config/dlm/cluster/cluster_name
 
@@ -735,13 +740,14 @@ vgchange --lock-start <vgname>
 .P
 
 To change the dlm cluster name in the VG when the dlm cluster name has
-already changed, or the VG has already moved to a different cluster:
+already been changed on the hosts, or the VG has already moved to a
+different cluster:
 
 .IP \[bu] 2
 Ensure the VG is not being used by any hosts.
 
 .IP \[bu] 2
-The new dlm cluster must be active on the host making the change.
+The new dlm cluster must be running on the host making the change.
 The current dlm cluster name can be seen by:
 .br
 cat /sys/kernel/config/dlm/cluster/cluster_name
@@ -768,21 +774,44 @@ All LVs must be inactive to change the lock type.
 
 lvmlockd must be configured and running as described in USAGE.
 
+.IP \[bu] 2
 Change a local VG to a lockd VG with the command:
 .br
 vgchange --lock-type sanlock|dlm <vgname>
 
+.IP \[bu] 2
 Start the VG on hosts to use it:
 .br
 vgchange --lock-start <vgname>
 
+.P
 
 .SS changing a lockd VG to a local VG
 
-Stop the lockd VG on all hosts, then run:
+All LVs must be inactive to change the lock type.
+
+.IP \[bu] 2
+Start the VG on the host making the change:
+.br
+vgchange --lock-start <vgname>
+
+.IP \[bu] 2
+Stop the VG on all other hosts:
+.br
+vgchange --lock-stop <vgname>
+
+.IP \[bu] 2
+Change the VG lock type to none on the host where the VG is started:
 .br
 vgchange --lock-type none <vgname>
 
+.P
+
+If the VG cannot be started with the previous lock type, then the lock
+type can be forcibly changed to none with:
+
+vgchange --lock-type none --lock-opt force <vgname>
+
 To change a VG from one lockd type to another (i.e. between sanlock and
 dlm), first change it to a local VG, then to the new type.
 


