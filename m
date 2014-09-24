From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:23 +0000 (UTC)
Subject: master - cleanup: drop duplicate const usage
Message-ID: <20140924085723.78215613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cef6dd721ad79bf73bbf5fa0d381ad7b71e1555
Commit:        3cef6dd721ad79bf73bbf5fa0d381ad7b71e1555
Parent:        f809fa5a7865bb59d9a2616629523429dd7ec629
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 15:51:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

cleanup: drop duplicate const usage

const char == const char const.
---
 lib/device/dev-type.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 6fcfa08..001248d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -460,9 +460,9 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 		       uint32_t types_to_exclude, uint32_t types_no_prompt,
 		       int yes, force_t force)
 {
-	static const char const _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
-	static const char const _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
-	static const char const _msg_wiping[] = "Wiping %s signature on %s.";
+	static const char _msg_failed_offset[] = "Failed to get offset of the %s signature on %s.";
+	static const char _msg_failed_length[] = "Failed to get length of the %s signature on %s.";
+	static const char _msg_wiping[] = "Wiping %s signature on %s.";
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;


