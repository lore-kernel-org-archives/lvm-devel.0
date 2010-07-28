From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:59 +0200
Subject: [PATCH 13/14] Reorder read_ahead check
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <5286d44287ec2037f99f13c2721a63165a5c78a3.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Wait for udev for debug print - otherwise read_ahead check tries
to access device not yet available through udev.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 10b9e0b..2af9c28 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -633,9 +633,16 @@ static int _create(int argc, char **argv, void *data __attribute__((unused)))
 
 	r = 1;
 
+	if (!_udev_cookie)
+		(void) dm_udev_wait(cookie);
+
 	if (_switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
+	dm_task_destroy(dmt);
+
+	return r;
+
       out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);
-- 
1.7.2


