From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:53 +0200
Subject: [PATCH 6/9] Use Require.private: field
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <9e64344dfc93664471d823834bf59683b95df332.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move devmapper to Require.private: field.
Remove unneeded libs from Libs.private:

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/libdevmapper-event.pc.in |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.pc.in b/daemons/dmeventd/libdevmapper-event.pc.in
index 49cad5a..839433f 100644
--- a/daemons/dmeventd/libdevmapper-event.pc.in
+++ b/daemons/dmeventd/libdevmapper-event.pc.in
@@ -6,7 +6,6 @@ includedir=@includedir@
 Name: devmapper-event
 Description: device-mapper event library
 Version: @DM_LIB_PATCHLEVEL@
-Requires: devmapper
 Cflags: -I${includedir}
 Libs: -L${libdir} -ldevmapper-event
-Libs.private: -lpthread -ldl
+Requires.private: devmapper
-- 
1.7.0.1


