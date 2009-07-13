From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 03:09:51 -0400
Subject: [PATCH 4/4] Remove READ_REQUIRE_RESIZEABLE flag from vg_read() interface - no users.
In-Reply-To: <1247468991-13691-4-git-send-email-dwysocha@redhat.com>
References: <1247468991-13691-1-git-send-email-dwysocha@redhat.com>
	<1247468991-13691-2-git-send-email-dwysocha@redhat.com>
	<1247468991-13691-3-git-send-email-dwysocha@redhat.com>
	<1247468991-13691-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1247468991-13691-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The checks for RESIZEABLE_VG should now be inside the various functions that
have to do such operations.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    3 ---
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 21b1c7e..b2fbeba 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -104,7 +104,6 @@ struct pv_segment;
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
-#define READ_REQUIRE_RESIZEABLE	0x00040000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index eb1192d..ef1b6ff 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2994,9 +2994,6 @@ vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
 	if (flags & READ_ALLOW_EXPORTED)
 		status &= ~EXPORTED_VG;
 
-	if (flags & READ_REQUIRE_RESIZEABLE)
-		status |= RESIZEABLE_VG;
-
 	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
 }
 
-- 
1.6.0.6


