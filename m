From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 09:51:26 -0400
Subject: master - WHATS_NEW: conditionally reject raid convert
Message-ID: <201703171351.v2HDpQ2Y015881@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ebf39da91678238ebea4f13cb1252bbc70238c5
Commit:        6ebf39da91678238ebea4f13cb1252bbc70238c5
Parent:        76709aaf39dd0f233ef36b4c49e5378d3735ec62
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 14:51:10 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 14:51:10 2017 +0100

WHATS_NEW: conditionally reject raid convert

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d27b6b..daca9e0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Conditionally reject raid convert to striped/raid0* after reshape
   Ensure raid6 upconversion restrictions
   Adjust mirror+raid DSOs to aforementioned lvconvert --repair
   Disable lvmetad when lvconvert --repair is run.


