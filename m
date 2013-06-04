From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:52 +0000 (UTC)
Subject: dev-mornfall-activate - Clean-up: Fix copy-n-paste error
Message-ID: <20130604192752.997C860F1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7061b74ec6850651e5610a8da7ff0a16b1f6d155
Commit:        7061b74ec6850651e5610a8da7ff0a16b1f6d155
Parent:        09cc5f65dbe34027c91011907e25ea4c21edfd13
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri May 17 14:30:29 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri May 31 11:14:37 2013 -0500

Clean-up:  Fix copy-n-paste error

Description for --with-raid should be s/mirror/raid/.
---
 configure    |    2 +-
 configure.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index b58c52d..b167274 100755
--- a/configure
+++ b/configure
@@ -1588,7 +1588,7 @@ Optional Packages:
                           [[TYPE=internal]]
   --with-mirrors=TYPE     mirror support: internal/shared/none
                           [[TYPE=internal]]
-  --with-raid=TYPE        mirror support: internal/shared/none
+  --with-raid=TYPE        raid support: internal/shared/none
                           [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
diff --git a/configure.in b/configure.in
index 75e0d84..b4dfc19 100644
--- a/configure.in
+++ b/configure.in
@@ -364,7 +364,7 @@ dnl -- raid inclusion type
 AC_MSG_CHECKING(whether to include raid)
 AC_ARG_WITH(raid,
 	    AC_HELP_STRING([--with-raid=TYPE],
-			   [mirror support: internal/shared/none
+			   [raid support: internal/shared/none
 			    [[TYPE=internal]]]),
 	    RAID=$withval, RAID=internal)
 AC_MSG_RESULT($RAID)


