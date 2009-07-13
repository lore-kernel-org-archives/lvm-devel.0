From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 00:12:37 -0400
Subject: [PATCH 4/5] Add VG APIs to liblvm/.exported_symbols.
In-Reply-To: <1247458358-24590-4-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-2-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-3-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1247458358-24590-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the following VG APIs to liblvm/.exported_symbols:
-lvm_reload_config
-lvm_vg_create
-lvm_vg_extend
-lvm_vg_set_extent_size
-lvm_vg_write
-lvm_vg_close
-lvm_vg_remove

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 1b65e10..5a6d92e 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -1,3 +1,9 @@
 lvm_create
 lvm_destroy
-lvm_reload_config
\ No newline at end of file
+lvm_reload_config
+lvm_vg_create
+lvm_vg_extend
+lvm_vg_set_extent_size
+lvm_vg_write
+lvm_vg_close
+lvm_vg_remove
-- 
1.6.0.6


