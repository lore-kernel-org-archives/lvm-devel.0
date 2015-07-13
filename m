From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Jul 2015 21:35:31 +0000 (UTC)
Subject: master - man lvmlockd: update method for changing lock type
Message-ID: <20150713213531.E8AAB61439@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d41bab402805c8813bb8eb0b18f3da97bb79fdf7
Commit:        d41bab402805c8813bb8eb0b18f3da97bb79fdf7
Parent:        3da88b89172b588bef69d62e18ed5db127b2c845
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 13 16:33:58 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 13 16:33:58 2015 -0500

man lvmlockd: update method for changing lock type

The old description did not work.
---
 man/lvmlockd.8.in |   37 ++++++++++++++++++++++++++++++-------
 1 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 659fead..9318350 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -500,20 +500,43 @@ A small sanlock VG dedicated to holding the global lock can avoid the case
 where the GL lock must be manually enabled after a vgremove.
 
 
-.SS changing lock type
+.SS changing a local VG to a lockd VG
+
+All LVs must be inactive to change the lock type.
+
+lvmlockd must be configured and running as described in USAGE.
+
+Change a local VG to a lockd VG with the command:
+.br
+vgchange \-\-lock\-type sanlock|dlm <vg_name>
+
+Start the VG on any hosts that need to use it:
+.br
+vgchange \-\-lock\-start <vg_name>
 
-To change a local VG to a lockd VG:
 
-vgchange --lock-type sanlock|dlm <vg_name>
+.SS changing a clvm VG to a lockd VG
 
 All LVs must be inactive to change the lock type.
 
-To change a clvm VG to a lockd VG:
+1. Change the clvm VG to a local VG.
+
+Within a running clvm cluster, change a clvm VG to a local VG with the
+command:
+
+vgchange \-cn <vg_name>
+
+If the clvm cluster is no longer running on any nodes, then extra options
+can be used forcibly make the VG local.  Caution: this is only safe if all
+nodes have stopped using the VG:
 
-vgchange --lock-type sanlock|dlm <vg_name>
+vgchange \-\-config 'global/locking_type=0 global/use_lvmlockd=0'
+.RS
+\-cn <vg_name>
+.RE
 
-Changing a lockd VG to a local VG is not yet generally allowed.
-(It can be done partially in certain recovery cases.)
+2. After the VG is local, follow the steps described in "changing a local
+VG to a lockd VG".
 
 
 .SS vgremove and vgreduce with sanlock VGs


