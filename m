From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:29 +0000 (GMT)
Subject: main - cov: memleak dir descriptor
Message-ID: <20210727225029.9784E385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec9dd728aa00de692f4b003e12394aa9cdda9446
Commit:        ec9dd728aa00de692f4b003e12394aa9cdda9446
Parent:        308c6f31c3d79b370b163660f3ec38042a00289f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:36:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:22 2021 +0200

cov: memleak dir descriptor

opendir() missed closedir().
---
 lib/device/dev-type.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 067a9ffad..89791bebe 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -180,6 +180,9 @@ int dev_is_used_by_active_lv(struct cmd_context *cmd, struct device *dev, int *u
 		}
 	}
 
+	if (closedir(d))
+		log_sys_debug("closedir", holders_path);
+
 	if (used_by_lv_count)
 		*used_by_lv_count = used_count;
 	if (used_by_dm_name)


