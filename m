From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Sep 2019 04:52:39 -0400
Subject: stable-2.02 - WHATS_NEW: vgcreate/vgextend logical block size
Message-ID: <201909240852.x8O8qdem006904@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fcda0d9752bf06b619d29aa6738b4ac52acedfc
Commit:        9fcda0d9752bf06b619d29aa6738b4ac52acedfc
Parent:        f758d16b30afd1848ea874b5ebd20185c5300320
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 10:15:27 2019 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 24 10:51:50 2019 +0200

WHATS_NEW: vgcreate/vgextend logical block size

(cherry picked from commit 3a0d493d918510d863ddbdbc63d8a8ccb6ca2dd9)

Conflicts:
	WHATS_NEW
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a5bda3..3811c5c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Prevent creating VGs with PVs with different logical block sizes.
   Pvmove runs in exlusively activating mode for exclusively active LVs.
   Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.


