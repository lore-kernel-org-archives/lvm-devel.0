From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:44 +0000 (UTC)
Subject: master - WHATS_NEW: reporting commands and -o-/-o+ extension
Message-ID: <20151030145244.EFB84609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f1c63c812ba5f79768f23b8d6d2e2965a458e0e
Commit:        3f1c63c812ba5f79768f23b8d6d2e2965a458e0e
Parent:        dd52721b68a7c393a54149649f518f4e2d9440b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 15:50:35 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:50:35 2015 +0100

WHATS_NEW: reporting commands and -o-/-o+ extension

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 415efc7..3808cb6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.133 - 
 ======================================
+  Support repeated -o|--options for reporting commands.
+  Support -o- and -o# for reporting commands to remove and compact fields.
   Fix missing PVs from pvs output if vgremove is run concurrently.
   Remove unwanted error message when running pvs/vgs/lvs and vgremove at once.
   Check newly created VG's metadata do not overlap in metadata ring buffer.


