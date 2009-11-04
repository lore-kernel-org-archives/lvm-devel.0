From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 04 Nov 2009 11:55:03 +0100
Subject: [PATCH] Do not support dmsetup udev{flags, complete, complete_all, cookies} when udev_sync is disabled and tiny fix for udevcomplete
Message-ID: <4AF15D87.5010507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just a tiny cleanup - we should be consistent here and disable dmsetup udev{flags,complete,
complete_all,cookies} commands if udev_sync is disabled, not udevcomplete_all and
udevcookies only.

This patch also includes a tiny fix for one specific situation and that is when using
automatically generated flags to control udev rules (to switch them off) while the
software does not use udev_sync interface yet - we have cookies with flags, but with
no semaphore identifier (it is zero). So dmsetup udevcomplete should detect this
and it should not try to find such semaphore. It should not show any errors that
the semaphore with identifier "0" could not be found...

Peter


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a7f1d25..69685e9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -758,6 +758,40 @@ static int _splitname(int argc, char **argv, void *data __attribute((unused)))
 	return r;
 }
 
+#ifndef UDEV_SYNC_SUPPORT
+
+static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
+
+static int _udevflags(int args, char **argv, void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
+static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
+static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
+static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
+{
+	log_error(_cmd_not_supported);
+
+	return 0;
+}
+
+#else	/* UDEV_SYNC_SUPPORT */
+
 static uint32_t _get_cookie_value(char *str_value)
 {
 	unsigned long int value;
@@ -821,32 +855,22 @@ static int _udevcomplete(int argc, char **argv, void *data __attribute((unused))
 	if (!(cookie = _get_cookie_value(argv[1])))
 		return 0;
 
-	/* strip flags from the cookie and use cookie magic instead */
-	cookie = (cookie & ~DM_UDEV_FLAGS_MASK) |
-		  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
-
-	return dm_udev_complete(cookie);
-}
-
-#ifndef UDEV_SYNC_SUPPORT
-static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
-
-static int _udevcomplete_all(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
-{
-	log_error(_cmd_not_supported);
-
-	return 0;
-}
+	/*
+	 * Strip flags from the cookie and use cookie magic instead.
+	 * If the cookie has non-zero prefix and the base is zero then
+	 * this one carries flags to control udev rules only and it is
+	 * not meant to be for notification (e.g. setting the flags
+	 * automatically to disable the rules for software that does
+	 * not use udev synchronisation interface).
+	 */
+	if (!(cookie &= ~DM_UDEV_FLAGS_MASK))
+		return 1;
 
-static int _udevcookies(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
-{
-	log_error(_cmd_not_supported);
+	cookie |= DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT;
 
-	return 0;
+	return dm_udev_complete(cookie);
 }
 
-#else	/* UDEV_SYNC_SUPPORT */
-
 static char _yes_no_prompt(const char *prompt, ...)
 {
 	int c = 0, ret = 0;


