From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:05 -0400
Subject: master - cov: index off by one
Message-ID: <201810151555.w9FFt5ld020535@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=77aa055e8a34eb7f0036b6240f3f93dc429c0c02
Commit:        77aa055e8a34eb7f0036b6240f3f93dc429c0c02
Parent:        2ab784440a2cbde7448a3f5e315f7e8a8cbcf729
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:43:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: index off by one

Basically apply stable patch fdb6ef8a85e9adc4805202b3200b17bd3b351982 to internal libdm version.
---
 device_mapper/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 111fff6..eec31d7 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1765,7 +1765,7 @@ static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min,
 			return 0;
 		}
 		devmapper += 12; /* skip fixed prefix */
-		for (i = 0; devmapper[i] && devmapper[i] != ' ' && i < sizeof(root); ++i)
+		for (i = 0; devmapper[i] && devmapper[i] != ' ' && i < sizeof(root)-1; ++i)
 			root[i] = devmapper[i];
 		root[i] = 0;
 		_unmangle_mountinfo_string(root, buf);


