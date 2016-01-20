From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 20 Jan 2016 00:59:27 +0000 (UTC)
Subject: master - clvmd: Initialise udev.
Message-ID: <20160120005927.4529660D36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=509410bbbcc6fb72e985029e98c19315da36318a
Commit:        509410bbbcc6fb72e985029e98c19315da36318a
Parent:        2304286f68debd4755b44fa8b779b762142bfada
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 20 00:58:09 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 20 00:58:09 2016 +0000

clvmd: Initialise udev.

Since commit 2fc126b00d83991c6a2f3ed9aa61457294a4c45e, the library
code requires udev to be initialised for device scanning and
clvmd can fail to find VGs if devices/external_device_info_source
is set to "udev".
---
 WHATS_NEW                     |    3 ++-
 daemons/clvmd/lvm-functions.c |    5 +++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c5db715..6f909ab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,9 @@
 Version 2.02.141 - 
 ====================================
+  Initialise udev in clvmd for use in device scanning. (2.02.116)
   Add seg_le_ranges report field for common format when displaying seg devices.
   Honour report/list_item_separator for seg_metadata_le_ranges report field.
-  Don't mark hidden devs in -o devices,metadata_devices,seg_pe_ranges (2.02.140).
+  Don't mark hidden devs in -o devices,metadata_devices,seg_pe_ranges.(2.02.140)
   Change LV sizes in seg_pe_ranges report field to match underlying devices.
   Add kernel_cache_settings report field for cache LV settings used in kernel.
 
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 03963cc..2537c57 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -901,8 +901,12 @@ int init_clvm(struct dm_hash_table *excl_uuid)
 	if (!get_initial_state(excl_uuid))
 		log_error("Cannot load initial lock states.");
 
+	if (!udev_init_library_context())
+		stack;
+
 	if (!(cmd = create_toolcontext(1, NULL, 0, 1, 1, 1))) {
 		log_error("Failed to allocate command context");
+		udev_fin_library_context();
 		return 0;
 	}
 
@@ -929,6 +933,7 @@ void destroy_lvm(void)
 	if (cmd) {
 		memlock_dec_daemon(cmd);
 		destroy_toolcontext(cmd);
+		udev_fin_library_context();
 		cmd = NULL;
 	}
 }


