From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 27 May 2009 14:45:27 +0200
Subject: [PATCH 3/9] Udev integration: add semaphore IPC to wait for udev rule completion
In-Reply-To: <4A1A8CAE.2000803@redhat.com>
References: <4A1A8CAE.2000803@redhat.com>
Message-ID: <4A1D35E7.4000404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should set the cookie value to 0 if the notification is disabled!

Peter

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index ef249dc..d24584d 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -794,8 +794,10 @@ int dm_udev_notif_sem_open(uint32_t *cookie)
 	int fd;
 	uint32_t gen_cookie;
 
-	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported())
+	if (!dm_udev_notif_is_enabled() || !dm_cookie_supported()) {
+		*cookie = 0;
 		return 1;
+	}
 
 	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
 		log_error("Failed to open /dev/urandom to create random cookie value.");


