From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 27 Feb 2017 09:06:38 -0500
Subject: master - git: Upstream repository moved to sourceware.org
Message-ID: <201702271406.v1RE6cdL014774@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c41e99948819e896d9d06b4a8192ec7a63facf65
Commit:        c41e99948819e896d9d06b4a8192ec7a63facf65
Parent:        4f7631b4adb9c6fff5cd47b5bd733ee716d05c8f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 27 13:52:51 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 27 14:05:50 2017 +0000

git: Upstream repository moved to sourceware.org

The fedorahosted git repository shuts down tomorrow:
  https://communityblog.fedoraproject.org/fedorahosted-sunset-2017-02-28/

Our upstream git repository has moved back to sourceware.org.
Mailing list hosting is not changing.

Gitweb:
  https://www.sourceware.org/git/?p=lvm2

Git:
  git://sourceware.org/git/lvm2.git
  ssh://sourceware.org/git/lvm2.git
  http://sourceware.org/git/lvm2.git

Example command to change the origin of a repository clone:
  Public:
    git remote set-url origin git://sourceware.org/git/lvm2.git
  Committers:
    git remote set-url origin git+ssh://sourceware.org/git/lvm2.git
---
 README    |    5 +++--
 WHATS_NEW |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/README b/README
index a0e3c9e..c7e267e 100644
--- a/README
+++ b/README
@@ -6,11 +6,12 @@ Installation instructions are in INSTALL.
 There is no warranty - see COPYING and COPYING.LIB.
 
 Tarballs are available from:
+  ftp://sourceware.org/pub/lvm2/
   ftp://sources.redhat.com/pub/lvm2/
 
 The source code is stored in git:
-  http://git.fedorahosted.org/git/lvm2.git
-  git clone git://git.fedorahosted.org/git/lvm2.git
+  https://sourceware.org/git/?p=lvm2.git
+  git clone git://sourceware.org/git/lvm2.git
 
 Mailing list for general discussion related to LVM2:
   linux-lvm at redhat.com
diff --git a/WHATS_NEW b/WHATS_NEW
index d2e750b..63cc2d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Upstream git moved to https://sourceware.org/git/?p=lvm2
   Support conversion of raid type, stripesize and number of disks
   Reject writemostly/writebehind in lvchange during resynchronization.
   Deactivate active origin first before removal for improved workflow.


