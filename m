From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 17:27:49 -0400
Subject: master - WHATS_NEW: adjust mirror+raid DSOs to lvconvert --repair
Message-ID: <201703162127.v2GLRn6t017934@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b917b12e2caee33e425a4d29aab93863f7dea4bf
Commit:        b917b12e2caee33e425a4d29aab93863f7dea4bf
Parent:        b0336e8b3cb04908119e4cea816e39cdccd1a115
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 22:27:30 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 22:27:30 2017 +0100

WHATS_NEW: adjust mirror+raid DSOs to lvconvert --repair

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4d5e52f..81d1dc2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Adjust mirror+raid DSOs to aforementioned lvconvert --repair
   Disable lvmetad when lvconvert --repair is run.
   Remove obsolete lvmchange binary - convert to built-in command.
   Lvdisplay [-m] shows more informations for cached volumes.


