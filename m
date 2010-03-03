From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:53 +0100
Subject: [PATCH 07/15] Move include before DEFS+=
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <e97025f1f34e0ffc63b63e778979954db0c7bd06.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch moves inclusion of the make.tmpl before DEFS modification,
so it goes in the same order on the compilation line.
(i.e. HAVE_CONFIG_H goes first)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index ce3e058..6ff3bff 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -47,11 +47,11 @@ endif
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+include $(top_builddir)/make.tmpl
+
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-include $(top_builddir)/make.tmpl
-
 device-mapper: all
 
 .PHONY: install_dynamic install_static install_include \
-- 
1.7.0


