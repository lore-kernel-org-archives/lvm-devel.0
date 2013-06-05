From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:01:56 +0000 (UTC)
Subject: dev-mornfall-lvmcache - cleanup: add some FIXMEs
Message-ID: <20130605120156.D708B613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e1ac7faf132e83393dda628f72cdaecfc4bf9e8
Commit:        4e1ac7faf132e83393dda628f72cdaecfc4bf9e8
Parent:        dfca5dac9ca3ed0ca186b9d79d6b2cacedc4ea37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:16:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:05 2013 +0200

cleanup: add some FIXMEs

---
 lib/activate/activate.c |    1 +
 lib/device/dev-io.c     |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b3439ad..670b85c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -794,6 +794,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	int r;
 	struct dev_manager *dm;
 	struct dm_status_raid *status;
+	/* FIXME: find a better way for this, it is fragile */
 	static char *cached_dev_health = NULL;
 	static const struct logical_volume *cached_lv = NULL;
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 2846caf..bb50ae4 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -437,6 +437,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		}
 
 		dev_close_immediate(dev);
+		// FIXME: dev with DEV_ALLOCED is released
+		// but code is referencing it
 	}
 
 	if (critical_section())


