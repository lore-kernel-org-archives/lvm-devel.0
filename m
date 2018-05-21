From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 May 2018 17:27:18 -0400
Subject: master - man vgexport: expand description
Message-ID: <201805212127.w4LLRI7S011611@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73ae68e1c4308c3391fe3b21f2c721f659343f98
Commit:        73ae68e1c4308c3391fe3b21f2c721f659343f98
Parent:        6029d6d8d8198aee17ec8972c333477f2c581bff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 21 16:26:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 21 16:26:49 2018 -0500

man vgexport: expand description

---
 man/vgexport.8_des |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/man/vgexport.8_des b/man/vgexport.8_des
index 66d3af3..9f276af 100644
--- a/man/vgexport.8_des
+++ b/man/vgexport.8_des
@@ -1,8 +1,19 @@
-vgexport makes inactive VGs unknown to the system. In this state, all the
-PVs in the VG can be moved to a different system, from which
-\fBvgimport\fP(8) can then be run.
+vgexport changes a VG into the exported state, which ensures that the VG
+and its disks are not being used, and cannot be used until the VG is
+imported by \fBvgimport\fP(8).  Putting a VG into an unusable, offline
+state can be useful when doing things like moving a VG's disks to another
+system.  Exporting a VG provides some protection from its LVs being
+accidentally used, or being used by an automated system before it's ready.
 
-Most LVM tools ignore exported VGs.
+A VG cannot be exported until all of its LVs are inactive.
+
+LVM commands will ignore an exported VG or report an error if a command
+tries to use it.
+
+For an exported VG, the vgs command will display \"x\" in the third VG
+attribute, and the pvs command will display \"x\" in the second PV
+attribute.  Both vgs and pvs will display \"exported\" from the export
+report field.
 
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).


