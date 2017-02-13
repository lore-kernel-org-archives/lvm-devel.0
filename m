From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 21:22:54 +0000 (UTC)
Subject: master - WHATS_NEW: items from command definitions patch set
Message-ID: <20170213212254.6463460FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c816e8b6365f777a2e555824ae2425f85869c5c5
Commit:        c816e8b6365f777a2e555824ae2425f85869c5c5
Parent:        717363bb9427c02addeb22ef77396132cb30c782
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 13 15:22:26 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 15:22:26 2017 -0600

WHATS_NEW: items from command definitions patch set

---
 WHATS_NEW |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b497c7e..3fbef6f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,14 @@
 Version 2.02.169 - 
 =====================================
+  Add lvconvert --swapmetadata for previous non-specific command.
+  Add lvconvert --startpoll for previous non-specific command.
+  Add lvconvert --mergethin for specific --merge case.
+  Add lvconvert --mergemirrors for specific --merge case.
+  Add lvconvert --mergesnapshot for specific --merge case.
+  Split up lvconvert code based on command definitions.
+  Split up lvchange code based on command definitions.
+  Generate help output and man pages from command definitions.
+  Add command definitions and match every command to one.
   Add extra memory page when limiting pthread stack size in clvmd.
   Support striped/raid0* <-> raid10_near conversions
   Support shrinking of RaidLvs


