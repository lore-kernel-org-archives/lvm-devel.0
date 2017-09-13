From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 13 Sep 2017 15:56:30 -0400
Subject: master - README: Include new github links
Message-ID: <201709131956.v8DJuUPY008912@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=901c919d2208f9a13b1c46cc4755620c3b1b0a07
Commit:        901c919d2208f9a13b1c46cc4755620c3b1b0a07
Parent:        03efec27123efb43c3350ceaf5675fd68d8b3f50
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 13 20:20:04 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 13 20:20:04 2017 +0100

README: Include new github links

We've decided to mirror the upstream code onto github for the
convenience of people already using that platform.
---
 README |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/README b/README
index c7e267e..9fe0a0d 100644
--- a/README
+++ b/README
@@ -8,10 +8,15 @@ There is no warranty - see COPYING and COPYING.LIB.
 Tarballs are available from:
   ftp://sourceware.org/pub/lvm2/
   ftp://sources.redhat.com/pub/lvm2/
+  https://github.com/lvmteam/lvm2/releases
 
 The source code is stored in git:
   https://sourceware.org/git/?p=lvm2.git
   git clone git://sourceware.org/git/lvm2.git
+mirrored to:
+  https://github.com/lvmteam/lvm2
+  git clone https://github.com/lvmteam/lvm2.git
+  git clone git at github.com:lvmteam/lvm2.git
 
 Mailing list for general discussion related to LVM2:
   linux-lvm at redhat.com
@@ -29,6 +34,14 @@ and multipath-tools:
   dm-devel at redhat.com
   Subscribe from https://www.redhat.com/mailman/listinfo/dm-devel
 
+Website:
+  https://sourceware.org/lvm2/
+
+Report upstream bugs at:
+  https://bugzilla.redhat.com/enter_bug.cgi?product=LVM%20and%20device-mapper
+or open issues at:
+  https://github.com/lvmteam/lvm2/issues
+
 The source code repository used until 7th June 2012 is accessible here:
   http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/?cvsroot=lvm2.
 


