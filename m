From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 14 Nov 2013 08:43:10 -0600
Subject: [PATCH 13/13] lvm2app: Remove forward declarations.
In-Reply-To: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
References: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
Message-ID: <1384440190-5759-14-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove the forward struct declaration.  This isn't needed for
implementing opaque data pointers.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 0940b6f..a91640a 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -84,20 +84,13 @@ const char *lvm_library_get_version(void);
 /******************************** structures ********************************/
 
 /**
- * Opaque structures - do not use directly.  Internal structures may change
- * without notice between releases, whereas this API will be changed much less
- * frequently.  Backwards compatibility will normally be preserved in future
- * releases.  On any occasion when the developers do decide to break backwards
- * compatibility in any significant way, the LVM_LIBAPI number (included in
- * the library's soname) will be incremented.
- */
-struct lvm;
-struct physical_volume;
-struct volume_group;
-struct logical_volume;
-struct lv_segment;
-struct pv_segment;
-struct lvm_lv_create_params;
+ * Opaque C pointers - Internal structures may change without notice between
+ * releases, whereas this API will be changed much less frequently.  Backwards
+ * compatibility will normally be preserved in future releases.  On any occasion
+ * when the developers do decide to break backwards compatibility in any
+ * significant way, the LVM_LIBAPI number (included in the library's soname)
+ * will be incremented.
+ */
 
 /**
  * \class lvm_t
-- 
1.8.2.1


