From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:15 +0200
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

use selinux pkgconfig file instead of hardcoding the contents

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 b657090... d4ca036... M	libdm/libdevmapper.pc.in
 libdm/libdevmapper.pc.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.pc.in b/libdm/libdevmapper.pc.in
index b657090..d4ca036 100644
--- a/libdm/libdevmapper.pc.in
+++ b/libdm/libdevmapper.pc.in
@@ -8,4 +8,4 @@ Description: device-mapper library
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Libs.private: @SELINUX_LIBS@
+Requires.private: libselinux
-- 
1.5.4.3


