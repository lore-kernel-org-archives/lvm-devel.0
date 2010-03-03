From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:47 +0100
Subject: [PATCH 01/15] Update AC_PREREQ version to 2.61
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <53e3f7c464c3fc70069c93dad66ed0f72f9941c0.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Usage of AC_PROG_SED and AC_PROG_MKDIR_P requires autoconf version 2.61.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index aaa21c6..9ccde94 100644
--- a/configure.in
+++ b/configure.in
@@ -11,7 +11,7 @@
 ## Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 ################################################################################
 
-AC_PREREQ(2.57)
+AC_PREREQ(2.61)
 ################################################################################
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT
-- 
1.7.0


