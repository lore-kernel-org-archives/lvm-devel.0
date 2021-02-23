From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:03:56 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEW: update
Message-ID: <20210223140356.2DDAF3894427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f220e8d430f3ab94e3e85656a3f692c6dc4051f
Commit:        1f220e8d430f3ab94e3e85656a3f692c6dc4051f
Parent:        0ab7fce2b3e11c89ac5091c919750a7f7f23ad32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 15:02:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 15:03:03 2021 +0100

WHATS_NEW: update

---
 WHATS_NEW | 1 +
 1 file changed, 1 insertion(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7a9491a8b..14b6ec2b9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix problem with unbound variable usage within fsadm.
   Avoid removing LVs on error path of lvconvert during creation volumes.
   Fix crashing lvdisplay when thin volume was waiting for merge.
   Support option --errorwhenfull when converting volume to thin-pool.


