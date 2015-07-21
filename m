From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 21 Jul 2015 09:01:01 +0000 (UTC)
Subject: master - wiping: add "Wiping skipped." for the message context to be complete
Message-ID: <20150721090101.4F80C60F5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3fddb0fbbcabf73d3bcf2786cea31c179f13fae
Commit:        c3fddb0fbbcabf73d3bcf2786cea31c179f13fae
Parent:        697fb353dc5ecf813199c598eed07983868fdd56
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 21 11:00:43 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 21 11:00:43 2015 +0200

wiping: add "Wiping skipped." for the message context to be complete

---
 lib/device/dev-type.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 873e02e..db40792 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -530,6 +530,7 @@ static inline int _type_in_flag_list(const char *type, uint32_t flag_list)
 
 #define MSG_FAILED_SIG_OFFSET "Failed to get offset of the %s signature on %s."
 #define MSG_FAILED_SIG_LENGTH "Failed to get length of the %s signature on %s."
+#define MSG_WIPING_SKIPPED " Wiping skipped."
 
 static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       uint32_t types_to_exclude, uint32_t types_no_prompt,
@@ -549,7 +550,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 				log_error(MSG_FAILED_SIG_OFFSET, type, name);
 				return 0;
 			} else {
-				log_error("WARNING: " MSG_FAILED_SIG_OFFSET, type, name);
+				log_error("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
 				return 2;
 			}
 		}
@@ -558,7 +559,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 				log_error(MSG_FAILED_SIG_LENGTH, type, name);
 				return 0;
 			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH, type, name);
+				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
 				return 2;
 			}
 		}
@@ -568,7 +569,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 				log_error(MSG_FAILED_SIG_OFFSET, type, name);
 				return 0;
 			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_OFFSET, type, name);
+				log_warn("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
 				return 2;
 			}
 		}
@@ -577,7 +578,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 				log_error(MSG_FAILED_SIG_LENGTH, type, name);
 				return 0;
 			} else {
-				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH, type, name);
+				log_warn("WARNING: " MSG_FAILED_SIG_LENGTH MSG_WIPING_SKIPPED, type, name);
 				return 2;
 			}
 		}


