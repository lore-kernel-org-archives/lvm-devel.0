From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:31 +0800
Subject: [RFC 5/6] Add another policy for the missing device -- wait
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <1433749712-11837-6-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We add another policy for the missing device. If the missing deivce
could not come back with in the waiting time, then it will excute the
original policy(remove/allocate)
Not sure about the vsn() meaning, so I put down the kernel version...
---
 lib/config/config_settings.h | 2 ++
 lib/config/defaults.h        | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 885a2fa..bfea715 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1147,6 +1147,8 @@ cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activatio
 	"Defines how a device failure in a 'mirror' log LV is handled.\n"
 	"The mirror_image_fault_policy description for mirrored LVs\n"
 	"also applies to mirrored log LVs.\n")
+cfg(activation_mirror_keep_log_CFG, "mirror_keep_log", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MIRROR_KEEP_LOG, vsn(4, 2, 0), NULL,0, NULL, "Enable to wait for the missing device come back within a fixed time.\n")
+cfg(activation_mirror_keep_log_timeout_CFG, "mirror_keep_log_timeout", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MIRROR_KEEP_LOG_TIMEOUT, vsn(4, 2, 0), NULL, 0, NULL, "Defines the wating time.\n")
 
 cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, vsn(2, 2, 57),
 	"This has been replaced by the activation/mirror_image_fault_policy setting.\n",
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6793d01..6fbadfd 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -216,6 +216,8 @@
 
 #define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
+#define DEFAULT_MIRROR_KEEP_LOG 0
+#define DEFAULT_MIRROR_KEEP_LOG_TIMEOUT 60
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT 20
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
-- 
1.8.1.4


