From: Regid Ichira <regid23@nt1.in>
Date: Mon, 25 Feb 2013 00:11:14 +0200
Subject: [PATCH] minor. man/lvm.8.in: Whether or not the metadata should. the, not to.
Message-ID: <20130224221114.GD1552@nt1.in>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

  Shouldn't it read: Whether or not the metadata should ...?
---
Applied to V2_02_98, on top of
71f4934 - Zdenek Kabelac, 2013-02-23 : activation: fix pvmove partial t
---
 man/lvm.8.in |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 2ce0065..7de929c 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -181,7 +181,7 @@ Whether or not the device-mapper kernel driver is loaded.
 If you set this to \fIn\fP, no attempt will be made to contact the driver.
 .TP
 .BR \-A ", " \-\-autobackup " {" \fIy | \fIn }
-Whether or not to metadata should be backed up automatically after a change.
+Whether or not the metadata should be backed up automatically after a change.
 You are strongly advised not to disable this!
 See \fBvgcfgbackup\fP(8).
 .TP
-- 
1.7.10.4


