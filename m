From: David Teigland <teigland@sourceware.org>
Date: Thu, 16 Mar 2017 12:56:53 -0400
Subject: master - WHATS_NEW: disable lvmetad for repair
Message-ID: <201703161656.v2GGurm6015698@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8719d4e9430c4a2edaae9df4b53da97c718cc76
Commit:        c8719d4e9430c4a2edaae9df4b53da97c718cc76
Parent:        506d88a2ec8cc4960b907b2cf34ca5786d060943
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 16 11:56:19 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 16 11:56:19 2017 -0500

WHATS_NEW: disable lvmetad for repair

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25efd49..4d5e52f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Disable lvmetad when lvconvert --repair is run.
   Remove obsolete lvmchange binary - convert to built-in command.
   Lvdisplay [-m] shows more informations for cached volumes.
   Add option for lvcreate/lvconvert --cachemetadataformat auto|1|2.


