From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:22 +0100
Subject: [PATCH 4/9] Move include before DEFS+=
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <94a93c9a9ffb39504746117e744e497cfa18cb3a.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch moves inclusion of the make.tmpl before DEFS modification,
so we can have them in the same order on the in compilation line.
(i.e. HAVE_CONFIG_H goes first)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 6dd25ff..1884b21 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -47,11 +47,11 @@ endif
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+include ../make.tmpl
+
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-include ../make.tmpl
-
 device-mapper: all
 
 .PHONY: install_dynamic install_static install_include \
-- 
1.7.0


