From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 19:50:27 +0000 (GMT)
Subject: main - tests: add aux mdadm_assemble
Message-ID: <20210326195027.A47F93857C44@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c59b2aa216cb5649fe5e3f54230e85ee994869b
Commit:        4c59b2aa216cb5649fe5e3f54230e85ee994869b
Parent:        5ef8d845694c79683ebdbdeec69eb2e534f4b1d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:05:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:41 2021 +0100

tests: add aux mdadm_assemble

Wrapper for slowed version of mdadm --assemble
---
 test/lib/aux.sh | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6cf86bc38..0ce2b8b07 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -780,6 +780,22 @@ mdadm_create() {
 	done
 }
 
+mdadm_assemble() {
+	STRACE=
+	[ "$DM_DEV_DIR" = "/dev" ] && mdadm -V 2>&1 | grep " v3.2" && {
+		# use this 'trick' to slow down mdadm which otherwise
+		# is racing with udev rule since mdadm internally
+		# opens and closes raid leg devices in RW mode and then
+		# tries to get exlusive access to the leg device during
+		# insertion to kernel and fails during assembly
+		# There can be some other affected version of mdadm.
+		STRACE="strace -f -o /dev/null"
+	}
+
+	$STRACE mdadm --assemble "$@"
+	udev_wait
+}
+
 cleanup_md_dev() {
 	local IFS=$IFS_NL
 	local i


