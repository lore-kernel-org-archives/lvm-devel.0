From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:26 +0000 (UTC)
Subject: master - configure: correct message
Message-ID: <20150911195426.D7EE960F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19443035a613f3bd5e6028070cabd077279722c8
Commit:        19443035a613f3bd5e6028070cabd077279722c8
Parent:        8b8103efef9cc23eb8fe47cd7d16629560ffd2e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 21:16:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:46:34 2015 +0200

configure: correct message

---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 31f4b3a..169a500 100644
--- a/configure.in
+++ b/configure.in
@@ -157,7 +157,7 @@ AC_FUNC_VPRINTF
 
 ################################################################################
 dnl -- Disable dependency tracking
-AC_MSG_CHECKING(whether to disable dependency tracking)
+AC_MSG_CHECKING(whether to enable dependency tracking)
 AC_ARG_ENABLE(dependency-tracking,
 	      AC_HELP_STRING([--disable-dependency-tracking],
 			     [speeds up one-time build.]),


