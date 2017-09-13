From: Ilya Dryomov <idryomov@gmail.com>
Date: Wed, 13 Sep 2017 12:02:35 +0200
Subject: [PATCH RESEND] devices: recognise rbd devices
Message-ID: <1505296955-32764-1-git-send-email-idryomov@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Under single_major scheme introduced in kernel 3.14, rbd devices
support up to 16 partitions.  In pre-single_major mode, rbd driver
takes up the whole major.

Signed-off-by: Ilya Dryomov <idryomov@gmail.com>
---
 WHATS_NEW                 | 1 +
 lib/device/device-types.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index e6cc18db009b..f5f22eaa7b4a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Recognise RADOS block devices (RBD) in filter.
   Prevent raid1 split with trackchanges in a shared VG.
   Avoid double unlocking of client & lockspace mutexes in lvmlockd.
   Fix leaking of file descriptor for non-blocking filebased locking.
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 2834cd11fd3a..57b430173e56 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -64,5 +64,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"nvme", 64, "NVM Express"},
 	{"zvol", 16, "ZFS Zvols"},
 	{"VxDMP", 16, "Veritas Dynamic Multipathing"},
+	{"rbd", 16, "RADOS block device (RBD)"},
 	{"", 0, ""}
 };
-- 
2.4.3


