From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:48 +0100
Subject: [PATCH 02/15] Help display --disable-fsadm
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <552f4e1262733334e53990f8ddc7505c02741d8d.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As fsadm is installed by default - it's a common practice to rather
print help text in '--disable' form for such case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index 9ccde94..a973590 100644
--- a/configure.in
+++ b/configure.in
@@ -737,8 +737,8 @@ AC_ARG_ENABLE(pkgconfig,   [  --enable-pkgconfig      Install pkgconfig support]
 ################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
-AC_ARG_ENABLE(fsadm, [  --enable-fsadm          Enable fsadm],
-FSADM=$enableval)
+AC_ARG_ENABLE(fsadm, [AC_HELP_STRING([--disable-fsadm], [Disable fsadm])],
+	FSADM=$enableval)
 AC_MSG_RESULT($FSADM)
 
 ################################################################################
-- 
1.7.0


