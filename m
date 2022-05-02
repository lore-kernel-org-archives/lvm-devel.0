From: David Teigland <teigland@sourceware.org>
Date: Mon,  2 May 2022 14:47:44 +0000 (GMT)
Subject: main - improve description of devices option
Message-ID: <20220502144744.87EE63858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd28460017356d9a1a30a787b5572e9bcbf1c4a4
Commit:        dd28460017356d9a1a30a787b5572e9bcbf1c4a4
Parent:        494372b4eed0c8f6040e3357939eb7511ac25745
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 2 09:46:28 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 2 09:47:02 2022 -0500

improve description of devices option

---
 tools/args.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index c4d8fe7ff..57d2dfc52 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -245,8 +245,9 @@ arg(deviceidtype_ARG, '\0', "deviceidtype", string_VAL, 0, 0,
     "then it will override the default type that lvm would use.\n")
 
 arg(devices_ARG, '\0', "devices", pv_VAL, ARG_GROUPABLE, 0,
-    "Devices that the command can use. This option can be repeated\n"
-    "or accepts a comma separated list of devices. This overrides\n"
+    "Restricts the devices that are visible and accessible to the command.\n"
+    "Devices not listed will appear to be missing. This option can be\n"
+    "repeated, or accepts a comma separated list of devices. This overrides\n"
     "the devices file.\n")
 
 arg(devicesfile_ARG, '\0', "devicesfile", string_VAL, 0, 0,

