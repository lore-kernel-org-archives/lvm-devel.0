From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:52 +0200
Subject: [PATCH 5/9] Skip unneeded 'cat' command
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <df0cce0347bf77ff94d578a1b40004f25b6fd4ca.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 69fab00..6d9f681 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -142,14 +142,11 @@ STRIP=
 
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
-LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
-		     $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
+LIB_VERSION_LVM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION)
 
-LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
-		    $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}')
+LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION_DM)
 
-LIB_VERSION_APP := $(shell cat $(top_srcdir)/VERSION | \
-		     $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
+LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
 INCLUDES += -I. -I$(top_builddir)/include
 
-- 
1.7.0.1


