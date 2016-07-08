From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:27:10 +0000 (UTC)
Subject: master - dmstats: use canonical path when reporting errors
Message-ID: <20160708182710.21759610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cd39f1dc4013d5d9b150abe544187413daeaac9
Commit:        5cd39f1dc4013d5d9b150abe544187413daeaac9
Parent:        17cbcc85bdd31d6b1e0d3af8e43c39a8c58561b5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 17:06:35 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

dmstats: use canonical path when reporting errors

When a 'dmstats create --filemap' operation fails (e.g. during
open(2), close(2), or dm_stats_create_regions_from_fd()), use the
canonical version of the path. This avoids cryptic/confusing error
messages when symbolic links exist in the path argument given:

  # findmnt /var/lib/libvirt/images -otarget,source
  TARGET                  SOURCE
  /var/lib/libvirt/images /dev/mapper/vg_hex-lv_images

  # readlink /var/lib/libvirt/images/my.img
  /boot/my.img

  # dmstats create --filemap /var/lib/libvirt/images/my.img
  Cannot map file: not a device-mapper device.
  Could not create regions from file /var/lib/libvirt/images/my.img
  Command failed

Using the canonical path the error is immediately obvious:

  # dmstats create --filemap /var/lib/libvirt/images/my.img
  Cannot map file: not a device-mapper device.
  Could not create regions from file /boot/my.img
  Command failed
---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index eb7c83a..34e33d3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5034,7 +5034,7 @@ static int _stats_create_file(CMD_ARGS)
 	fd = open(abspath, O_RDONLY);
 
 	if (fd < 0) {
-		log_error("Could not open %s for reading", path);
+		log_error("Could not open %s for reading", abspath);
 		goto bad;
 	}
 
@@ -5060,12 +5060,12 @@ static int _stats_create_file(CMD_ARGS)
 						  bounds, alias);
 
 	if (close(fd))
-		log_error("Error closing %s", path);
+		log_error("Error closing %s", abspath);
 
 	fd = -1;
 
 	if (!regions) {
-		log_error("Could not create regions from file %s", path);
+		log_error("Could not create regions from file %s", abspath);
 		goto bad;
 	}
 


