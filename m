From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:33 +0000 (GMT)
Subject: main - aux: add clear_dev
Message-ID: <20230421125333.40FEE3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11562bcc6b9dc09eb0c5bccb69a7741dec9e626b
Commit:        11562bcc6b9dc09eb0c5bccb69a7741dec9e626b
Parent:        b030ef31de0897aac1964dce4368750bb1166d5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 01:35:31 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

aux: add clear_dev

Function that will use 'blkdiscard -z' and fallbacks
to 'dd' when such option is not available.
---
 test/lib/aux.sh | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9412a20af..3ab599f60 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -916,6 +916,42 @@ cleanup_idm_context() {
 	fi
 }
 
+
+#
+# clear device either with blkdiscard -z or fallback to 'dd'
+# $1  device_path
+# TODO: add support for parametrized [OPTION] usage (Not usable ATM)
+# TODO: -bs  blocksize  (defaults 512K)
+# TODO: -count  count/length  (defaults to whole device, otherwise in BS units)
+# TODO: -seek  offset/oseek  (defaults 0, begining of zeroing area in BS unit)
+clear_devs() {
+	local bs=
+	local count=
+	local seek=
+
+	while [ "$#" -ne 0 ] ; do
+		case "$1" in
+		"") ;;
+		"--bs") bs=$2; shift ;;
+		"--count") count=$2; shift ;;
+		"--seek") seek=$2; shift ;;
+		*TEST*) # Protection: only test devices with TEST in its path name can be zeroed
+			test -e NO_BLKDISCARD_Z || {
+				if blkdiscard -f -z "$1" ; then
+					shift
+					continue
+				fi
+				echo "Info: can't use 'blkdiscard -z' switch to 'dd'."
+				touch NO_BLKDISCARD_Z
+			}
+
+			dd if=/dev/zero of="$1" bs=512K oflag=direct $seek $count || true
+			;;
+		esac
+		shift
+	done
+}
+
 prepare_backing_dev() {
 	local size=${1=32}
 	shift

