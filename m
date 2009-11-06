From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 06 Nov 2009 09:26:39 +0100
Subject: [PATCH] Do not support dmsetup udev{flags, complete, complete_all, cookies} when udev_sync is disabled and tiny fix for udevcomplete
In-Reply-To: <4AF17469.9040408@redhat.com>
References: <4AF15D87.5010507@redhat.com>	<20091104112538.GA17814@wavehammer.waldi.eu.org>
	<4AF17469.9040408@redhat.com>
Message-ID: <4AF3DDBF.4090106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/04/2009 01:32 PM, Peter Rajnoha wrote:
> On 11/04/2009 12:25 PM, Bastian Blank wrote:
>> On Wed, Nov 04, 2009 at 11:55:03AM +0100, Peter Rajnoha wrote:
>>> Just a tiny cleanup - we should be consistent here and disable dmsetup udev{flags,complete,
>>> complete_all,cookies} commands if udev_sync is disabled, not udevcomplete_all and
>>> udevcookies only.
>>
>> What exactly are you trying to do? udevflags and udevcomplete is used in
>> your udev rules, which can be used without udev sync enabled at all.
>>
> 
> When udev_sync is disabled, there's no cookie set and propagated and no flags are set
> as well (dm_task_set_cookie is just a bogus function in this situation).

Well, upon further thought, maybe it would be better to still keep the flag support
even when udev_sync is disabled (either totally by not compiling it in or by using
the --noudevsync option). If there are important devices for which the rules should
be skipped, we should do this no matter what the udev_sync state is -enabled or disabled.

This would provide better handling when udev rules are installed, but udev_sync is
not compiled in (although this is not recommended). Also, the flags will work even when
--noudevsync option is selected, so we don't lose important flags then if there are any
(however, it will still require kernel >= 2.6.31).

Anyway, the cleanup should be made one way or the other. The patch for the second
alternative would be quite simple (with comments added to explain the situation):


diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ac0a758..8f9b5b5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1032,6 +1032,10 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
  * of udev rules we use by decoding the cookie prefix. When doing the
  * notification, we replace the cookie prefix with DM_COOKIE_MAGIC,
  * so we notify the right semaphore.
+ * It is still possible to use cookies for passing the flags to udev
+ * rules even when udev_sync is disabled. The base part of the cookie
+ * will be zero (there's no notification semaphore) and prefix will be
+ * set then. However, having udev_sync enabled is highly recommended.
  */
 #define DM_COOKIE_MAGIC 0x0D4D
 #define DM_UDEV_FLAGS_MASK 0xFFFF0000
@@ -1076,7 +1080,7 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 int dm_cookie_supported(void);
 
 /*
- * Udev notification functions.
+ * Udev synchronisation functions.
  */
 void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 121f020..43ef63a 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -886,6 +886,8 @@ int dm_udev_get_sync_support(void)
 
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
+	if (dm_cookie_supported())
+		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
 	*cookie = 0;
 
 	return 1;
@@ -1141,8 +1143,11 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
 
+	if (dm_cookie_supported())
+		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
+
 	if (!dm_udev_get_sync_support()) {
-		dmt->event_nr = *cookie = 0;
+		*cookie = 0;
 		return 1;
 	}
 
@@ -1159,8 +1164,7 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 		goto bad;
 	}
 
-	dmt->event_nr = (~DM_UDEV_FLAGS_MASK & *cookie) |
-			(flags << DM_UDEV_FLAGS_SHIFT);
+	dmt->event_nr |= ~DM_UDEV_FLAGS_MASK & *cookie;
 	dmt->cookie_set = 1;
 
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 186f8f0..888edff 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -843,9 +843,17 @@ static int _udevcomplete(int argc, char **argv, void *data __attribute((unused))
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
 
-	/* strip flags from the cookie and use cookie magic instead */
-	cookie = (cookie & ~DM_UDEV_FLAGS_MASK) |
-		  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
+	/*
+	 * Strip flags from the cookie and use cookie magic instead.
+	 * If the cookie has non-zero prefix and the base is zero then
+	 * this one carries flags to control udev rules only and it is
+	 * not meant to be for notification. Return with success in this
+	 * situation.
+	 */
+	if (!(cookie &= ~DM_UDEV_FLAGS_MASK))
+		return 1;
+
+	cookie |= DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT;
 
 	return dm_udev_complete(cookie);
 }


