From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:41 -0400
Subject: master - cleanup: missing dots and indent
Message-ID: <201803151004.w2FA4frR023671@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=285413b502e1f0f5a016b24c93b871419381c1fc
Commit:        285413b502e1f0f5a016b24c93b871419381c1fc
Parent:        d794444715d9a762d2b6f06fe465ef6348085673
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 21:00:20 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 11:01:04 2018 +0100

cleanup: missing dots and indent

---
 lib/device/dev-io.c     |    4 ++--
 lib/metadata/metadata.c |    6 ++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index f9422b1..cb3a234 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -1185,13 +1185,13 @@ const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 	}
 
 	if (!dev_read_buf(dev, offset, len, reason, buf)) {
-		log_error("Read from %s failed", dev_name(dev));
+		log_error("Read from %s failed.", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
 	if (!dev_read_buf(dev, offset2, len2, reason, buf + len)) {
-		log_error("Circular read from %s failed", dev_name(dev));
+		log_error("Circular read from %s failed.", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2e77a55..b5b97c2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5623,10 +5623,8 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 			}
 			lvmcache_force_next_label_scan();
 			lvmcache_label_scan(cmd);
-			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0)) {
-				/* vgname not found after scanning */
-				return SUCCESS;
-			}
+			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0))
+				return SUCCESS; /* vgname not found after scanning */
 		}
 	}
 


