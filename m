From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Aug 2014 22:48:50 +0000 (UTC)
Subject: master - autoreconf
Message-ID: <20140822224850.A753C60E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66326e2fb8c84b57505f1396d394a96ec25e12c3
Commit:        66326e2fb8c84b57505f1396d394a96ec25e12c3
Parent:        83b5cb3ed52b14d1bbe522168bbc63aba1c84475
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 22 23:47:44 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 22 23:47:44 2014 +0100

autoreconf

---
 configure |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 40ab256..be3d34d 100755
--- a/configure
+++ b/configure
@@ -7136,7 +7136,7 @@ fi
 $as_echo "$LVM1" >&6; }
 
 case "$LVM1" in
-  none|share) ;;
+  none|shared) ;;
   internal)
 $as_echo "#define LVM1_INTERNAL 1" >>confdefs.h
  ;;


