From: Bastian Blank <waldi@debian.org>
Date: Sat, 8 Jun 2013 11:56:57 +0200
Subject: [PATCH 3/3] udev: Use udev monitor
In-Reply-To: <20130608094939.GA3065@mail.waldi.eu.org>
References: <20130608094939.GA3065@mail.waldi.eu.org>
Message-ID: <20130608095657.GC3132@mail.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 libdm/libdm-common.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 92 insertions(+), 1 deletion(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d028029..fdabf80 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -26,6 +26,7 @@
 #include <dirent.h>
 
 #ifdef UDEV_SYNC_SUPPORT
+#  include <poll.h>
 #  include <libudev.h>
 #endif
 
@@ -64,7 +65,9 @@ static int _udev_disabled = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
 static struct udev *_udev;
+static struct udev_monitor *_udev_monitor;
 static int _udev_running = -1;
+static unsigned int _udev_monitor_inflight;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
 #endif
@@ -1992,6 +1995,55 @@ bad:
 	return 0;
 }
 
+static struct udev_monitor *_get_udev_monitor(void)
+{
+	struct udev *udev = _get_udev();
+
+	if (!udev)
+		return 0;
+
+	if (!_udev_monitor) {
+		log_debug("Opening udev monitor");
+
+		_udev_monitor = udev_monitor_new_from_netlink(udev, "udev");
+		if (!_udev_monitor)
+			goto_bad;
+
+		udev_monitor_filter_add_match_subsystem_devtype(_udev_monitor, "block", "disk");
+		udev_monitor_enable_receiving(_udev_monitor);
+	}
+
+	return _udev_monitor;
+
+bad:
+	log_error("Could not get udev monitor. Assuming udev is not running.");
+	return 0;
+}
+
+static void _close_udev_monitor(void)
+{
+	log_debug("Closing udev monitor");
+	udev_monitor_unref(_udev_monitor);
+	_udev_monitor = NULL;
+}
+
+static void _push_udev_monitor_inflight(void)
+{
+	_udev_monitor_inflight++;
+	if (_udev_monitor_inflight == 0)
+		abort();
+	_get_udev_monitor();
+}
+
+static void _pop_udev_monitor_inflight(void)
+{
+	if (_udev_monitor_inflight == 0)
+		abort();
+	_udev_monitor_inflight--;
+	if (_udev_monitor_inflight == 0)
+		_close_udev_monitor();
+}
+
 static int _check_udev_is_running(void)
 {
 	struct udev *udev;
@@ -2166,6 +2218,7 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 
 	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
+	_push_udev_monitor_inflight();
 
 	log_debug_activation("Udev cookie 0x%" PRIx32 " assigned to "
 			     "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, _task_type_disp(dmt->type), dmt->type, 
@@ -2195,10 +2248,48 @@ int dm_udev_complete(uint32_t cookie)
 
 static int _udev_wait(uint32_t cookie)
 {
+	struct udev_monitor *monitor;
+	struct pollfd p = { -1, POLLIN, 0 };
+	int r = 0;
+
 	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
 
-	return_0;
+	cookie &= ~DM_UDEV_FLAGS_MASK;
+	log_debug("Udev cookie 0x%" PRIx32 " expected", cookie);
+
+	monitor = _get_udev_monitor();
+
+	p.fd = udev_monitor_get_fd(monitor);
+
+	while (!r)
+	{
+		// TODO: timeout
+		poll(&p, 1, -1);
+
+		struct udev_device *device = udev_monitor_receive_device(monitor);
+		struct udev_list_entry *l;
+
+		udev_list_entry_foreach(l, udev_device_get_properties_list_entry(device))
+		{
+			if (strcmp("DM_COOKIE", udev_list_entry_get_name(l)) == 0)
+			{
+				const char *value = udev_list_entry_get_value(l);
+				uint32_t cookie_current = strtol(value, NULL, 10) & ~DM_UDEV_FLAGS_MASK;
+				log_debug("Udev cookie 0x%" PRIx32 " found", cookie_current);
+
+				if (cookie == cookie_current)
+					r = 1;
+				break;
+			}
+		}
+
+		udev_device_unref(device);
+	}
+
+	_pop_udev_monitor_inflight();
+
+	return r;
 }
 
 int dm_udev_wait(uint32_t cookie)
-- 
I have never understood the female capacity to avoid a direct answer to
any question.
		-- Spock, "This Side of Paradise", stardate 3417.3


