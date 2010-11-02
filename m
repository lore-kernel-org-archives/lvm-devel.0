From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Nov 2010 15:10:41 +0100
Subject: [PATCH 1/3] Use include make.tmpl as other headers
In-Reply-To: <cover.1288706876.git.zkabelac@redhat.com>
References: <cover.1288706876.git.zkabelac@redhat.com>
Message-ID: <78864e28299ac9a789b48c40a80f1716bcf6052d.1288706876.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 include/Makefile.in |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/include/Makefile.in b/include/Makefile.in
index 0354d2e..0aba011 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -12,15 +12,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-SHELL = /bin/sh
-
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-LN_S = @LN_S@
-
-.PHONY: clean distclean all install pofile install_cluster install_device-mapper
+include $(top_builddir)/make.tmpl
 
 all: .symlinks_created
 
@@ -37,14 +33,4 @@ pofile: all
 
 device-mapper: all
 
-clean:
-
-install:
-
-install_cluster:
-
-install_device-mapper:
-
-install_lvm2:
-
 cflow: all
-- 
1.7.3.2


