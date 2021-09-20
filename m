From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:01 +0000 (GMT)
Subject: main - cov: check fid instance is created
Message-ID: <20210920133001.ECC7C3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f410035181d8c524ffc5d0f3edf512e8506b47d9
Commit:        f410035181d8c524ffc5d0f3edf512e8506b47d9
Parent:        e1840dd9e0b3be55281466e60a9a07cce068db4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 02:09:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: check fid instance is created

---
 tools/pvscan.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index d24ee5724..ec33c9a9a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1234,7 +1234,12 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		}
 
 		fmt = lvmcache_fmt(info);
-		fid = fmt->ops->create_instance(fmt, &fic);
+		if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
+			log_error("pvscan[%d] failed to create format instance.", getpid());
+			ret = 0;
+			continue;
+		}
+
 		vg = NULL;
 
 		mda1 = lvmcache_get_dev_mda(dev, 1);


