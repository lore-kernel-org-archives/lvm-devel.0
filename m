From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 17:33:20 -0400
Subject: master - WHATS_NEW: ensure raid6 upconversion restrictions
Message-ID: <201703162133.v2GLXKPv018459@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a3e30d1026d9bde85cda325b1c0a704e980b7db
Commit:        4a3e30d1026d9bde85cda325b1c0a704e980b7db
Parent:        b917b12e2caee33e425a4d29aab93863f7dea4bf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 22:33:08 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 22:33:08 2017 +0100

WHATS_NEW: ensure raid6 upconversion restrictions

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 81d1dc2..5d27b6b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Ensure raid6 upconversion restrictions
   Adjust mirror+raid DSOs to aforementioned lvconvert --repair
   Disable lvmetad when lvconvert --repair is run.
   Remove obsolete lvmchange binary - convert to built-in command.


