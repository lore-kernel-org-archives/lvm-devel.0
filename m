From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Mar 2016 08:33:53 +0000 (UTC)
Subject: master - dev: also check for blank sysfs value containing only '\n'
Message-ID: <20160322083353.6525160B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a47f0957fb95136985c97d0b7b4580044e3f68d
Commit:        2a47f0957fb95136985c97d0b7b4580044e3f68d
Parent:        e69e81388dd84598a37b8b77c17c393bf570cf75
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 22 09:29:24 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 22 09:29:24 2016 +0100

dev: also check for blank sysfs value containing only '\n'

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d912dea..bcee783 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -379,7 +379,7 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 		return 0;
 	}
 
-	if (!(len = strlen(buf))) {
+	if (!(len = strlen(buf)) || (len == 1 && buf[0] == '\n')) {
 		log_error("_get_sysfs_value: %s: no value", path);
 		return 0;
 	}


