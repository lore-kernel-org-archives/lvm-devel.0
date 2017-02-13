From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 21:36:40 +0000 (UTC)
Subject: master - WHATS_NEW: changes for recent command defs
Message-ID: <20170213213640.0CC7C60E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ab051df7a6f53ababb1c283af2ec4f8e1c7cac3
Commit:        5ab051df7a6f53ababb1c283af2ec4f8e1c7cac3
Parent:        c816e8b6365f777a2e555824ae2425f85869c5c5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 13 15:36:17 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 15:36:17 2017 -0600

WHATS_NEW: changes for recent command defs

---
 WHATS_NEW |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3fbef6f..c8b7fdc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,14 +1,16 @@
 Version 2.02.169 - 
 =====================================
-  Add lvconvert --swapmetadata for previous non-specific command.
-  Add lvconvert --startpoll for previous non-specific command.
-  Add lvconvert --mergethin for specific --merge case.
-  Add lvconvert --mergemirrors for specific --merge case.
-  Add lvconvert --mergesnapshot for specific --merge case.
+  Add lvconvert --swapmetadata, new specific way to swap pool metadata LVs.
+  Add lvconvert --startpoll, new specific way to start polling conversions.
+  Add lvconvert --mergethin, new specific way to merge thin snapshots.
+  Add lvconvert --mergemirrors, new specific way to merge split mirrors.
+  Add lvconvert --mergesnapshot, new specific way to combine cow LVs.
   Split up lvconvert code based on command definitions.
   Split up lvchange code based on command definitions.
   Generate help output and man pages from command definitions.
-  Add command definitions and match every command to one.
+  Verify all command line items against command definition.
+  Match every command run to one command definition.
+  Specify every allowed command definition/syntax in command-lines.in.
   Add extra memory page when limiting pthread stack size in clvmd.
   Support striped/raid0* <-> raid10_near conversions
   Support shrinking of RaidLvs


