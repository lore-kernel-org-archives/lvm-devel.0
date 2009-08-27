From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:22 +0200
Subject: [PATCH 01/15] configure.in: improve --with-clvmd description
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <fb6b50860da53ea726698ce206000cb30a3e7381.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It is possible to build all clvmd locking backends at once
but it doesn't really make sense in real life.

Improve the text to describe the most common scenarios.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 18bac05... f9e5d8d... M	configure.in
 configure.in |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 18bac05..f9e5d8d 100644
--- a/configure.in
+++ b/configure.in
@@ -325,7 +325,12 @@ AC_MSG_RESULT($REALTIME)
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
-  [  --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/corosync/none/all
+  [  --with-clvmd=TYPE       Build cluster LVM Daemon.
+                          The following locking combinations are valid:
+                           * cman,gulm             (RHEL4 or equivalent)
+                           * cman                  (RHEL5 or equivalent)
+                           * cman,corosync,openais (or selection of them)
+                           * none                  (disable build)
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])
-- 
1.5.4.3


