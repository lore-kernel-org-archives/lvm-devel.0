From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:45 +0000 (UTC)
Subject: master - cleanup: use static char[] array
Message-ID: <20120823124245.A0B03A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=449c09201030cfb18baf8481430bc150e43f5f07
Commit:        449c09201030cfb18baf8481430bc150e43f5f07
Parent:        90191e6ff2d156abceebafa342ec34274b6bd22a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 21 15:16:32 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:38 2012 +0200

cleanup: use static char[] array

---
 lib/device/device.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/device.c b/lib/device/device.c
index 3e5e2a4..a87ae7f 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -361,7 +361,7 @@ static unsigned long _dev_topology_attribute(const char *attribute,
 					     const char *sysfs_dir,
 					     struct device *dev)
 {
-	const char *sysfs_fmt_str = "%s/dev/block/%d:%d/%s";
+	static const char sysfs_fmt_str[] = "%s/dev/block/%d:%d/%s";
 	char path[PATH_MAX+1], buffer[64];
 	FILE *fp;
 	struct stat info;


