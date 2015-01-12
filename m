From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Jan 2015 13:12:28 +0000 (UTC)
Subject: master - pvscan: notify lvmetad about device that is gone and pvscan is run with device path instead of major:minor pair
Message-ID: <20150112131228.F0F2F601E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8dbe76734049a225a34bbbab383418b62acdcce1
Commit:        8dbe76734049a225a34bbbab383418b62acdcce1
Parent:        1e4a4d48aeb1e56a8df19ba73425eb5f7632c9d2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 12 13:50:11 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 12 13:59:51 2015 +0100

pvscan: notify lvmetad about device that is gone and pvscan is run with device path instead of major:minor pair

If pvscan is run with device path instead of major:minor pair and this
device still exists in the system and the device is not visible anymore
(due to a filter that is applied), notify lvmetad properly about this.

This makes it more consistent with respect to existing pvscan with
major:minor which already notifies lvmetad about device that is gone
due to filters.

However, if the device is not in the system anymore, we're not able
to translate the original device path into major:minor pair which
lvmetad needs for its action (lvmetad_pv_gone fn). So in this case,
we still need to use major:minor pair only, not device path. But at
least make "pvscan --cache DevicePath" as near as possible to "pvscan
--cahce <major>:<minor>" functionality.

Also add a note to pvscan man page about this difference when using
pvscan --cache with DevicePath and major:minor pair.
---
 WHATS_NEW       |    1 +
 man/pvscan.8.in |    8 ++++++--
 tools/pvscan.c  |   13 +++++++++++--
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 242c17d..11611dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Also notify lvmetad about filtered device if using pvscan --cache DevicePath.
   Use LVM's own selection instead of awk expressions in clvmd startup scripts.
   Do not filter out snapshot origin LVs as unusable devices for an LVM stack.
   Fix incorrect rimage names when converting from mirror to raid1 LV (2.02.112).
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index c1187ac..f976b40 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -69,8 +69,12 @@ If lvmetad has not yet cached any metadata or the filters have recently been
 changed, then all devices may be scanned, effectively ignoring the rest of
 the command line.  Otherwise, if all the devices referenced on the command line
 contain metadata in the default lvm2 format, other devices are not accessed.
-If metadata written using the obsolete GFS pool format is encountered, this is
-ignored and so lvmetad should not be used.
+If metadata written using the obsolete GFS pool or lvm1 format is encountered,
+this is ignored and so lvmetad should not be used.
+To notify lvmetad about a device that is not present in the system anymore,
+\fB\-\-major\fP and \fB\-\-minor\fP pair of that device must be always supplied,
+not \fBDevicePath\fP as pvscan is not able to translate the \fBDevicePath\fP
+into major and minor pair which lvmetad requires.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvmetad (8),
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3eaf0bb..4ab2ff7 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -239,8 +239,17 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		if (pv_name[0] == '/') {
 			/* device path */
 			if (!(dev = dev_cache_get(pv_name, cmd->lvmetad_filter))) {
-				log_error("Physical Volume %s not found.", pv_name);
-				ret = ECMD_FAILED;
+				if ((dev = dev_cache_get(pv_name, NULL))) {
+					if (!_clear_dev_from_lvmetad_cache(dev->dev, MAJOR(dev->dev), MINOR(dev->dev), handler)) {
+						stack;
+						ret = ECMD_FAILED;
+						break;
+					}
+				} else {
+					log_error("Physical Volume %s not found.", pv_name);
+					ret = ECMD_FAILED;
+					break;
+				}
 				continue;
 			}
 		}


