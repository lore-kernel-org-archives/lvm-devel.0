From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 13 Apr 2017 11:50:15 -0400
Subject: master - WHATS_NEW: raise region_size default
Message-ID: <201704131550.v3DFoF6W030297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b81b4aad24807d2aa4968aa9fc7d970a65623620
Commit:        b81b4aad24807d2aa4968aa9fc7d970a65623620
Parent:        c6a6ce6cd5a80e78094aa6420e3cb53a478eef76
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 13 17:49:58 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 13 17:49:58 2017 +0200

WHATS_NEW: raise region_size default

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56ad0ca..e59024b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  lvcreate - raise mirror/raid default regionsize to 2MiB
   Add missing configurable prefix to configuration file installation directory.
 
 Version 2.02.170 - 13th April 2017


