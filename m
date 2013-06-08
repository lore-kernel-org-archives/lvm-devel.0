From: Bastian Blank <waldi@debian.org>
Date: Sat, 8 Jun 2013 11:56:28 +0200
Subject: [PATCH 2/3] udev: Save open udev state
In-Reply-To: <20130608094939.GA3065@mail.waldi.eu.org>
References: <20130608094939.GA3065@mail.waldi.eu.org>
Message-ID: <20130608095627.GB3132@mail.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 libdm/libdm-common.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bcddc3b..d028029 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -63,6 +63,7 @@ static struct selabel_handle *_selabel_handle = NULL;
 static int _udev_disabled = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
+static struct udev *_udev;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
@@ -1977,17 +1978,30 @@ int dm_udev_wait(uint32_t cookie)
 
 #else		/* UDEV_SYNC_SUPPORT */
 
+static struct udev *_get_udev(void)
+{
+	if (!_udev)
+		_udev = udev_new();
+	if (!_udev)
+		goto_bad;
+
+	return _udev;
+
+bad:
+	log_error("Could not get udev state. Assuming udev is not running.");
+	return 0;
+}
+
 static int _check_udev_is_running(void)
 {
 	struct udev *udev;
 	struct udev_queue *udev_queue;
 	int r;
 
-	if (!(udev = udev_new()))
-		goto_bad;
+	if (!(udev = _get_udev()))
+		return 0;
 
 	if (!(udev_queue = udev_queue_new(udev))) {
-		udev_unref(udev);
 		goto_bad;
 	}
 
@@ -1996,12 +2010,11 @@ static int _check_udev_is_running(void)
 				     "Not using udev synchronisation code.");
 
 	udev_queue_unref(udev_queue);
-	udev_unref(udev);
 
 	return r;
 
 bad:
-	log_error("Could not get udev state. Assuming udev is not running.");
+	log_error("Could not get udev queue state. Assuming udev is not running.");
 	return 0;
 }
 
-- 
1.7.10.4

-- 
You can't evaluate a man by logic alone.
		-- McCoy, "I, Mudd", stardate 4513.3


