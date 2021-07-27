From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:38 +0000 (GMT)
Subject: main - cov: add initilizer
Message-ID: <20210727225038.C3ABD385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e2827f3b79b31fc8e7370f9064c0d206aa60897
Commit:        3e2827f3b79b31fc8e7370f9064c0d206aa60897
Parent:        a4eb378fe41218793f4c7e97b0d82d33643b5a67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 22:39:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: add initilizer

---
 lib/device/dev-type.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 89791bebe..0e77a009d 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -873,7 +873,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	const char *offset = NULL, *type = NULL, *magic = NULL,
 		   *usage = NULL, *label = NULL, *uuid = NULL;
 	loff_t offset_value;
-	size_t len;
+	size_t len = 0;
 
 	if (!blkid_probe_lookup_value(probe, "TYPE", &type, NULL)) {
 		if (_type_in_flag_list(type, types_to_exclude))


