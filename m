From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:26 +0200
Subject: [PATCH 3/5] Fix sign warning
In-Reply-To: <cover.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
Message-ID: <eab8a58e9bfe31e7a5795286198445072913443a.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Funny one -  'minor()' and 'major()'  should return 'int' according to
its man page.  But they are mapped to their gnu_dev friends.

i.e.
/usr/include/sys/sysmacros.h:

  extern unsigned int gnu_dev_minor (unsigned long long int __dev)

  #ifdef __GLIBC_HAVE_LONG_LONG
     # define minor(dev) gnu_dev_minor (dev)
  #endif

To keep warning quiet - cast to the 'expected' int.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 2b09670..788fd90 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -162,8 +162,8 @@ static void _umount(const char *device, int major, int minor)
 			continue; /* can't stat, skip this one */
 
 		if (S_ISBLK(st.st_mode) &&
-		    major(st.st_rdev) == major &&
-		    minor(st.st_rdev) == minor) {
+		    (int) major(st.st_rdev) == major &&
+		    (int) minor(st.st_rdev) == minor) {
 			syslog(LOG_ERR, "Unmounting invalid snapshot %s from %s.", device, words[1]);
                         if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
                                 syslog(LOG_ERR, "Failed to umount snapshot %s from %s: %s.",
-- 
1.7.4.4


