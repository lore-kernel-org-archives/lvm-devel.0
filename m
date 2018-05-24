From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 05:34:53 -0400
Subject: master - man: make generate
Message-ID: <201805240934.w4O9Yrh5002241@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c46dbfb14e00beaa143871dbcefc23612a63f4e0
Commit:        c46dbfb14e00beaa143871dbcefc23612a63f4e0
Parent:        4be1ec3da4eaa4ae315ca7c33265828dda37c58c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 23 19:46:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 23 19:46:47 2018 +0200

man: make generate

---
 man/vgexport.8_pregen |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 74aa597..1dd715e 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -8,11 +8,22 @@ vgexport - Unregister volume group(s) from the system
     [ \fIoption_args\fP ]
 .br
 .SH DESCRIPTION
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


