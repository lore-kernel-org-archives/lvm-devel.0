From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Feb 2019 16:55:11 -0500
Subject: master - config: make hints setting commented
Message-ID: <201902262155.x1QLtBAg012726@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c8fc18e8bfbf6e81fc26c7cde780711db748f112
Commit:        c8fc18e8bfbf6e81fc26c7cde780711db748f112
Parent:        90149c303e3c0d2d09b14d218924d0bc6c91469d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 15:54:30 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 26 15:54:30 2019 -0600

config: make hints setting commented

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index c8e629f..fc66117 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -255,7 +255,7 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"    compiled with udev support.\n"
 	"#\n")
 
-cfg(devices_hints_CFG, "hints", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_HINTS, vsn(2, 3, 2), NULL, 0, NULL,
+cfg(devices_hints_CFG, "hints", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_HINTS, vsn(2, 3, 2), NULL, 0, NULL,
 	"Use a local file to remember which devices have PVs on them.\n"
 	"Some commands will use this as an optimization to reduce device\n"
 	"scanning, and will only scan the listed PVs. Removing the hint file\n"


