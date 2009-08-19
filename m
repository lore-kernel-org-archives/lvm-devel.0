From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 19 Aug 2009 11:43:21 -0400
Subject: [PATCH] change the location of mirror device monitored message
Message-ID: <4A8C1D99.1010309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch moves the message telling that a mirror device is monitored
just before incrementing the usage counter so that the message is
displayed only when a mirror device is successfully registered.
The new location of the message is consistent with snapshot.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.02.52-20090818/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.52-20090818.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.52-20090818/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -241,8 +241,6 @@ int register_device(const char *device,
 
 	pthread_mutex_lock(&_register_mutex);
 
-	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
-
 	/*
 	 * Need some space for allocations.  1024 should be more
 	 * than enough for what we need (device mapper name splitting)
@@ -262,6 +260,8 @@ int register_device(const char *device,
 		lvm2_run(_lvm_handle, "_memlock_inc");
 	}
 
+	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
+
 	_register_count++;
 	r = 1;
 

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


