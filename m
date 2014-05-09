From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:43 +0000 (UTC)
Subject: dev-prajnoha-selout - cleanup: constify pointers
Message-ID: <20140509065643.BEB1360C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cc02c570e489426568e57ad0b8fdbd9eedccf87
Commit:        2cc02c570e489426568e57ad0b8fdbd9eedccf87
Parent:        9845f8c7674892d7760526b36e45c6425bd1950f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 13:09:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:46 2014 +0200

cleanup: constify pointers

---
 lib/device/dev-type.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 9d610d4..e0cae45 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -460,9 +460,9 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       uint32_t types_to_exclude, uint32_t types_no_prompt,
 		       int yes, force_t force)
 {
-	static const char _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
-	static const char _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
-	static const char _msg_wiping[] = "Wiping %s signature on %s.";
+	static const char const _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
+	static const char const _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
+	static const char const _msg_wiping[] = "Wiping %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;


