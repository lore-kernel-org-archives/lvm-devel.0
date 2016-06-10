From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jun 2016 18:39:51 +0000 (UTC)
Subject: master - WHATS_NEW: add recent changes
Message-ID: <20160610183951.26DF060F7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a667f5887f62525cebe7e57ffe6e049ce17c7dd
Commit:        8a667f5887f62525cebe7e57ffe6e049ce17c7dd
Parent:        ad414e5ad61a25b97975c1d2e060e65050d45a69
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 10 13:39:23 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 10 13:39:23 2016 -0500

WHATS_NEW: add recent changes

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f8ebda..9c8ae71 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.156 - 
 ================================
+  Don't allow duplicate orphan PVs to be used with vgcreate/vgextend/pvcreate.
+  Improve handling of lvmetad update failures.
   Yes/No prompt accepts '^[ ^t]*([Yy]([Ee]([Ss]|)|)|[Nn]([Oo]|))[ ^t]*$'.
   If available, also collect output from lsblk command when running lvmdump -s.
   Fix regression in blkdeactivate causing dm and md devices to be skipped. (2.02.155)


