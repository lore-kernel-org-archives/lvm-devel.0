From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 May 2017 11:50:56 -0400
Subject: master - man lvmsystemid: change some wording
Message-ID: <201705231550.v4NFou7O008990@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d261cd719eb5c5f8b6d96adcb954c2e36c7c3ec
Commit:        4d261cd719eb5c5f8b6d96adcb954c2e36c7c3ec
Parent:        5e8beb4023642eb3aabee0b9f9e54047044b0cb8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 23 10:50:08 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 23 10:50:41 2017 -0500

man lvmsystemid: change some wording

Clarify the wording in a couple cases.
---
 man/lvmsystemid.7_main |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 8c57042..9b36dc3 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -94,19 +94,18 @@ corrupting the PVs.  See the
 section for more information.
 
 .IP \[bu] 2
-The system ID does not protect devices in VG from programs other than LVM.
+The system ID does not protect devices in a VG from programs other than LVM.
 
 .IP \[bu] 2
-A host using an old version of LVM without the system ID feature will not
-recognize a system ID in VGs from other hosts.  Even though the old
-version of LVM is not blocked from reading a VG with a system ID, it is
-blocked from writing to the VG (or its LVs).  The system ID feature
-changes the write mode of a VG, making it appear read-only to previous
-versions of LVM.
-
-This also means that if a host downgrades its version of LVM, it would
+A host using an old LVM version (without the system ID feature) will not
+recognize a system ID set in VGs.  The old LVM can read a VG with a
+system ID, but is prevented from writing to the VG (or its LVs).
+The system ID feature changes the write mode of a VG, making it appear
+read-only to previous versions of LVM.
+
+This also means that if a host downgrades to the old LVM version, it would
 lose access to any VGs it had created with a system ID.  To avoid this,
-the system ID should be removed from VGs before downgrading to an LVM
+the system ID should be removed from local VGs before downgrading LVM to a
 version without the system ID feature.
 
 


