From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:25 +0000 (GMT)
Subject: stable-2.02 - README: update
Message-ID: <20201016191125.CCCEC396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de17c273de8e3b139cd694d76f9bde9154cc3aa2
Commit:        de17c273de8e3b139cd694d76f9bde9154cc3aa2
Parent:        ff75d40298dfe8dcfa222e2c0842d413dc68b228
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 12 12:05:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

README: update

---
 README | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/README b/README
index 9fe0a0d4e..31e5f318d 100644
--- a/README
+++ b/README
@@ -7,7 +7,6 @@ There is no warranty - see COPYING and COPYING.LIB.
 
 Tarballs are available from:
   ftp://sourceware.org/pub/lvm2/
-  ftp://sources.redhat.com/pub/lvm2/
   https://github.com/lvmteam/lvm2/releases
 
 The source code is stored in git:
@@ -42,6 +41,9 @@ Report upstream bugs at:
 or open issues at:
   https://github.com/lvmteam/lvm2/issues
 
-The source code repository used until 7th June 2012 is accessible here:
-  http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/?cvsroot=lvm2.
+The source code repository used until 7th June 2012 is accessible using CVS:
 
+  cvs -d :pserver:cvs at sourceware.org:/cvs/lvm2 login cvs
+  cvs -d :pserver:cvs at sourceware.org:/cvs/lvm2 checkout LVM2
+
+The password is cvs.


