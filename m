From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:22 +0000 (GMT)
Subject: main - config: change default use_devicesfile to 1
Message-ID: <20211007174322.B56F5385840C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c22392a3f903d6c086f7cc94978bdf8b072da6e
Commit:        6c22392a3f903d6c086f7cc94978bdf8b072da6e
Parent:        02626cbd33b58144eff5e4582f07560e37f212b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 16 09:52:13 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:06:49 2021 -0500

config: change default use_devicesfile to 1

---
 lib/config/defaults.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 66eece53a..a7a2a06df 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -322,7 +322,7 @@
 
 #define DEFAULT_MD_COMPONENT_CHECKS "auto"
 
-#define DEFAULT_USE_DEVICES_FILE 0
+#define DEFAULT_USE_DEVICES_FILE 1
 #define DEFAULT_DEVICES_FILE "system.devices"
 
 #define DEFAULT_SEARCH_FOR_DEVNAMES "auto"


