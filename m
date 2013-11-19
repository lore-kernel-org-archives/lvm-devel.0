From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:47 +0000 (UTC)
Subject: master - lvm2app: Remove forward declarations.
Message-ID: <20131119205647.F123360F74@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12d5e53953f1dacd911190cacc153dc2343878fe
Commit:        12d5e53953f1dacd911190cacc153dc2343878fe
Parent:        fe5b538c14c47e2e206d13c17f0225e39470d720
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 16:06:05 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:44 2013 -0600

lvm2app: Remove forward declarations.

Remove the forward struct declaration.  This isn't needed for
implementing opaque data pointers.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

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


