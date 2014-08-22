From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Aug 2014 22:44:09 +0000 (UTC)
Subject: master - configure: Fix shared lvm1 typo.
Message-ID: <20140822224409.1BCDD61046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83b5cb3ed52b14d1bbe522168bbc63aba1c84475
Commit:        83b5cb3ed52b14d1bbe522168bbc63aba1c84475
Parent:        a67c484fac6daaa3437258072021f122950b7d8f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 22 23:42:55 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 22 23:42:55 2014 +0100

configure: Fix shared lvm1 typo.

via https://bugs.gentoo.org/520640
---
 WHATS_NEW    |    1 +
 configure.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79dbf01..af6ced4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Fix typo breaking configure --with-lvm1=shared.
   Modify lvresize code to handle raid/mirrors and physical extents.
   Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
diff --git a/configure.in b/configure.in
index 1b8c338..70f3b78 100644
--- a/configure.in
+++ b/configure.in
@@ -271,7 +271,7 @@ AC_ARG_WITH(lvm1,
 AC_MSG_RESULT($LVM1)
 
 case "$LVM1" in
-  none|share) ;;
+  none|shared) ;;
   internal) AC_DEFINE([LVM1_INTERNAL], 1,
 		      [Define to 1 to include built-in support for LVM1 metadata.]) ;;
   *) AC_MSG_ERROR([--with-lvm1 parameter invalid]) ;;


