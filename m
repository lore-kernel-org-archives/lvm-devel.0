From: David Teigland <teigland@sourceware.org>
Date: Fri,  5 Nov 2021 21:25:03 +0000 (GMT)
Subject: main - fix device name from devno for partitions
Message-ID: <20211105212503.1D735385840A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4067e84c7884f2b46effdf31418f66cc0b902bb
Commit:        b4067e84c7884f2b46effdf31418f66cc0b902bb
Parent:        62533ae3fad9fece6f27e3fae7b56e40c66438fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 5 16:21:23 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 5 16:21:23 2021 -0500

fix device name from devno for partitions

sysfs files for partitions are different from
whole devices and will require more work to translate
to device names.
---
 lib/device/dev-cache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index ce82a9303..e71cef38d 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2125,7 +2125,7 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 		}
 
 		if (!(dir = opendir(path)))
-			return NULL;
+			goto try_partition;
 
 		while ((dirent = readdir(dir))) {
 			if (dirent->d_name[0] == '.')
@@ -2175,6 +2175,7 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 	 * major minor #blocks name
 	 */
 
+try_partition:
 	if (!(fp = fopen("/proc/partitions", "r")))
 		return NULL;
 


