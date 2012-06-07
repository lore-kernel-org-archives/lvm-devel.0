From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  7 Jun 2012 12:48:55 +0000 (UTC)
Subject: LVM2: master - Update source code location in README.
Message-ID: <20120607124855.49DF5225F@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=LVM2.git;a=commitdiff;h=859165e005f2b94a069d8d9ef69bfe57c919a512
Commit:        859165e005f2b94a069d8d9ef69bfe57c919a512
Parent:        64a3ac8f51789ae58e0b5f7b5b7bb0b036bcfd30
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 7 13:48:13 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 7 13:48:13 2012 +0100

Update source code location in README.

Change CVS to git and mention lvm2-commits list.
---
 README |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/README b/README
index bd6214c..e327702 100644
--- a/README
+++ b/README
@@ -8,19 +8,21 @@ There is no warranty - see COPYING and COPYING.LIB.
 Tarballs are available from:
   ftp://sources.redhat.com/pub/lvm2/
 
-To access the CVS tree use:
-  cvs -d :pserver:cvs at sources.redhat.com:/cvs/lvm2 login
-  CVS password: cvs
-  cvs -d :pserver:cvs at sources.redhat.com:/cvs/lvm2 co LVM2
+The source code is stored in git:
+  http://git.fedorahosted.org/git/LVM2.git
+  git clone git://git.fedorahosted.org/git/LVM2.git
 
 Mailing list for general discussion related to LVM2:
   linux-lvm at redhat.com
   Subscribe from https://www.redhat.com/mailman/listinfo/linux-lvm
 
-Mailing list for LVM2 development, patches and commits:
+Mailing lists for LVM2 development, patches and commits:
   lvm-devel at redhat.com
   Subscribe from https://www.redhat.com/mailman/listinfo/linux-lvm
 
+  lvm2-commits at lists.fedorahosted.org (Read-only archive of commits)
+  Subscribe from https://fedorahosted.org/mailman/listinfo/lvm2-commits
+
 Mailing list for device-mapper development, including kernel patches
 and multipath-tools:
   dm-devel at redhat.com


