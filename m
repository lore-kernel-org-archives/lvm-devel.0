From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:47 +0200
Subject: [PATCH 01/14] Skip VPATH usage
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <1bcc8c3d176c6fc011bfbf3d9ac832592ccc1393.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not use VPATH as we may get wrong builds when $srcdir has
complete build and different $builddir is used later.
Files from $builddir need to be used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 include/Makefile.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/Makefile.in b/include/Makefile.in
index 3023d4a..0354d2e 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -17,7 +17,6 @@ SHELL = /bin/sh
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 LN_S = @LN_S@
 
-- 
1.7.2


