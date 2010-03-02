From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:19 +0100
Subject: [PATCH 1/9] Help display --disable-fsadm
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <fdfc56d4c31cbc0961ed1d9229da143afc5732fe.1267529065.git.zkabelac@redhat.com>
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
index aaa21c6..4053f7f 100644
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


