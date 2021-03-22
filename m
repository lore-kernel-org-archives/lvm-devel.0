From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:54 +0000 (GMT)
Subject: dev-next - config: change default use_devicesfile to 1
Message-ID: <20210322153954.41CCD385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63662e2de6e19358987a495d9ad957acc92441d5
Commit:        63662e2de6e19358987a495d9ad957acc92441d5
Parent:        8ebfc607db62f9162f54ba3414fd52dcfafd57bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 16 09:52:13 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 22 10:38:26 2021 -0500

config: change default use_devicesfile to 1

---
 lib/config/defaults.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2870dee12..8f83d35d7 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -323,7 +323,7 @@
 
 #define DEFAULT_MD_COMPONENT_CHECKS "auto"
 
-#define DEFAULT_USE_DEVICES_FILE 0
+#define DEFAULT_USE_DEVICES_FILE 1
 #define DEFAULT_DEVICES_FILE "system.devices"
 
 #define DEFAULT_SEARCH_FOR_DEVNAMES "auto"


