From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 12 Aug 2020 10:06:10 +0000 (GMT)
Subject: master - Update README
Message-ID: <20200812100610.8B1EA3857C40@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=135d16fbb808da1d37d33258812f2eca4466c5bc
Commit:        135d16fbb808da1d37d33258812f2eca4466c5bc
Parent:        231cdd0efbe73c7a2a4c69969df7e0f5b63f7f2c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 12 12:05:36 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Aug 12 12:05:36 2020 +0200

Update README

---
 README | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/README b/README
index 38a9778fd..3e4508c8b 100644
--- a/README
+++ b/README
@@ -1,7 +1,6 @@
 This tree contains the LVM2 and device-mapper tools and libraries.
 
-This is development branch, for stable 2.02 release see 2018-06-01-stable
-branch.
+This is development branch, for stable 2.02 release see stable-2.02 branch.
 
 For more information about LVM2 read the changelog in the WHATS_NEW file.
 Installation instructions are in INSTALL.
@@ -10,7 +9,6 @@ There is no warranty - see COPYING and COPYING.LIB.
 
 Tarballs are available from:
   ftp://sourceware.org/pub/lvm2/
-  ftp://sources.redhat.com/pub/lvm2/
   https://github.com/lvmteam/lvm2/releases
 
 The source code is stored in git:
@@ -45,6 +43,9 @@ Report upstream bugs at:
 or open issues at:
   https://github.com/lvmteam/lvm2/issues
 
-The source code repository used until 7th June 2012 is accessible here:
-  http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/?cvsroot=lvm2.
+The source code repository used until 7th June 2012 is accessible using CVS:
 
+  cvs -d :pserver:cvs at sourceware.org:/cvs/lvm2 login cvs
+  cvs -d :pserver:cvs at sourceware.org:/cvs/lvm2 checkout LVM2
+
+The password is cvs.


