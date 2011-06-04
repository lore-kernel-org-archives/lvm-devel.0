From: Milan Broz <mbroz@redhat.com>
Date: Sat,  4 Jun 2011 21:03:35 +0200
Subject: [PATCH] Workaround for kernel 3.0 & uname
Message-ID: <1307214215-13987-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With recent ernel 3.0 update sme distros
has uname in form "3.0-rc1".

This patch temporary workarounds uname detection
(because with the new release string libdevmapper
initialization fails.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/ioctl/libdm-iface.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f54cf1d..02b3470 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -152,6 +152,7 @@ static int _uname(void)
 {
 	static int _uts_set = 0;
 	struct utsname _uts;
+	int parts;
 
 	if (_uts_set)
 		return 1;
@@ -160,10 +161,18 @@ static int _uname(void)
 		log_error("uname failed: %s", strerror(errno));
 		return 0;
 	}
-	if (sscanf(_uts.release, "%d.%d.%d",
+
+	parts = sscanf(_uts.release, "%d.%d.%d",
 			&_kernel_major,
 			&_kernel_minor,
-			&_kernel_release) != 3) {
+			&_kernel_release);
+
+	if (parts == 1 && _kernel_major >= 3) {
+		_kernel_minor = 0;
+		_kernel_release = 0;
+	} else if (parts == 2 && _kernel_major >= 3) {
+		_kernel_release = 0;
+	} else if (parts != 3) {
 		log_error("Could not determine kernel version used.");
 		return 0;
 	}
-- 
1.7.5.3


