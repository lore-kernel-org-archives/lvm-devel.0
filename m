From: Ville Skyttä <ville.skytta@iki.fi>
Date: Tue, 17 Dec 2013 20:26:10 +0200
Subject: [PATCH 1/2] Man page syntax fixes.
Message-ID: <1387304771-19004-1-git-send-email-ville.skytta@iki.fi>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/dmsetup.8.in | 2 +-
 man/lvm.8.in     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 93621a5..599c843 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -484,7 +484,7 @@ Default subsystem is LVM.
 .B status
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-\noflush ]
+.RB [ \-\-noflush ]
 .RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 13e66d0..02a8c0d 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -46,7 +46,7 @@ being created in the filesystem for them.
 \fBdumpconfig\fP \(em Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
-\fBdevtypes\fP \(dm Display the recognised built-in block device types.
+\fBdevtypes\fP \(em Display the recognised built-in block device types.
 .TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
-- 
1.8.3.1


