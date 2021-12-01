From: David Teigland <teigland@sourceware.org>
Date: Wed,  1 Dec 2021 20:39:45 +0000 (GMT)
Subject: main - pvscan: fix error message for invalid devname
Message-ID: <20211201203945.3D975385840C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c42a05c3ec8608e438fca435e3cbe6d306af80c6
Commit:        c42a05c3ec8608e438fca435e3cbe6d306af80c6
Parent:        05d9a013516f23e27b04b6933705c6ae45f9f5b2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 1 14:36:40 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 1 14:38:17 2021 -0600

pvscan: fix error message for invalid devname

uninitialized name buffer used in message.
fixes "pvs_online: include devname in pvid files"
---
 lib/device/dev-cache.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b5f355484..825e348b4 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2102,7 +2102,7 @@ int setup_devices_for_online_autoactivation(struct cmd_context *cmd)
 static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 {
 	char path[PATH_MAX];
-	char devname[PATH_MAX];
+	char devname[PATH_MAX] = { 0 };
 	char namebuf[NAME_LEN];
 	char line[1024];
 	int major = MAJOR(devno);
@@ -2114,6 +2114,9 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 	struct dirent *dirent;
 	FILE *fp;
 
+	if (!devno)
+		return NULL;
+
 	/*
 	 * $ ls /sys/dev/block/8:0/device/block/
 	 * sda
@@ -2251,6 +2254,8 @@ struct device *setup_dev_in_dev_cache(struct cmd_context *cmd, dev_t devno, cons
 	if (devname) {
 		if (stat(devname, &buf) < 0) {
 			log_error("Cannot access device %s for %d:%d.", devname, major, minor);
+			if (!devno)
+				return_NULL;
 			if (!(devname = _get_devname_from_devno(cmd, devno))) {
 				log_error("No device name found from %d:%d.", major, minor);
 				return_NULL;


