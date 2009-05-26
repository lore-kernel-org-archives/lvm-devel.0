From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 26 May 2009 14:17:27 +0200
Subject: [PATCH 4/9] Udev integration: add cookie support for dmsetup
In-Reply-To: <4A1A8CB5.1080508@redhat.com>
References: <4A1A8CB5.1080508@redhat.com>
Message-ID: <4A1BDDD7.9020306@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...Milan has added some lines to pvmove test recently. But it fails
with udev patches -- it waits for notification which will never come.
We can't wait wait for notification when dmsetup's "--notable"
is set while creating devices -- there's no uevent for this to unlock
the wait :)

So this should be applied on top of the patch "4/9 add cookie support
for dmsetup":


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8db38b0..be094c0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -572,6 +572,9 @@ static int _create(int argc, char **argv, void *data __attribute((unused)))
 				    _read_ahead_flags))
 		goto out;
 
+	if (_switches[NOTABLE_ARG])
+		dm_udev_notif_disable();
+
 	if (!dm_udev_notif_sem_open(&cookie))
 		goto out;
 


