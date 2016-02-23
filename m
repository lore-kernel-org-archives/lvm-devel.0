From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:32 +0000 (UTC)
Subject: master - coverity: use same arithmetic for both major and minor
Message-ID: <20160223204132.7716761051@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ddfec5b51a46faab3f64de3e07dc52e0adaf81bc
Commit:        ddfec5b51a46faab3f64de3e07dc52e0adaf81bc
Parent:        9e3a9eab0ebf06fb5ed969269e11cb9b31d033fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 21:16:08 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:17 2016 +0100

coverity: use same arithmetic for both major and minor

Run all arithmetic in the same 'dev_t' type.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7ad8982..2d59cf4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -316,7 +316,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 0)))
 				goto_out;
 
-			tmp_dev->dev = MKDEV((dev_t)sm->logs[0].major, sm->logs[0].minor);
+			tmp_dev->dev = MKDEV((dev_t)sm->logs[0].major, (dev_t)sm->logs[0].minor);
 			if (device_is_usable(tmp_dev, (struct dev_usable_check_params)
 					     { .check_empty = 1,
 					       .check_blocked = 1,


