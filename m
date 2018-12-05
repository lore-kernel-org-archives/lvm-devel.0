From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Dec 2018 12:32:58 -0500
Subject: master - man lvmlockd: lvextend with gfs2
Message-ID: <201812051732.wB5HWwtd005106@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=752b1e95f4f12225e6ed9302f078b3545e758549
Commit:        752b1e95f4f12225e6ed9302f078b3545e758549
Parent:        3d2fd95af78c6f8a34c2d602285bd2230d89b3fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 5 11:31:58 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 5 11:31:58 2018 -0600

man lvmlockd: lvextend with gfs2

---
 man/lvmlockd.8_main |   33 ++++++++++++++++++++++++++-------
 1 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index ebf57da..50b3473 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -773,6 +773,28 @@ vgchange --lock-type none --lock-opt force <vgname>
 After the VG is local, follow the steps described in "changing a local VG
 to a shared VG".
 
+.SS extending an LV active on multiple hosts
+
+With lvmlockd, a new procedure is required to extend an LV while it is
+active on multiple hosts (e.g. when used under gfs2):
+
+1. On one node run the lvextend command:
+.br
+.nf
+   lvextend --lockopt skiplv -L Size VG/LV
+.fi
+
+2. On each node using the LV, refresh the LV:
+.br
+.nf
+   lvchange --refresh VG/LV
+.fi
+
+3. On one node extend gfs2 (or comparable for other applications):
+.br
+.nf
+   gfs2_grow VG/LV
+.fi
 
 .SS limitations of shared VGs
 
@@ -806,12 +828,12 @@ Visible usage differences between shared VGs (using lvmlockd) and
 clvm/clustered VGs (using clvmd):
 
 .IP \[bu] 2
-lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or
-clvmd (locking_type=3), but not both.
+lvm.conf is configured to use lvmlockd by setting use_lvmlockd=1.
+clvmd used locking_type=3.
 
 .IP \[bu] 2
-vgcreate --shared creates a shared VG, and vgcreate --clustered y
-creates a clvm/clustered VG.
+vgcreate --shared creates a shared VG.  vgcreate --clustered y
+created a clvm/clustered VG.
 
 .IP \[bu] 2
 lvmlockd adds the option of using sanlock for locking, avoiding the
@@ -826,9 +848,6 @@ lvmlockd commands always apply to the local host, and never have an effect
 on a remote host.  (The activation option 'l' is not used.)
 
 .IP \[bu] 2
-lvmlockd works with thin and cache pools and LVs.
-
-.IP \[bu] 2
 lvmlockd saves the cluster name for a shared VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 


