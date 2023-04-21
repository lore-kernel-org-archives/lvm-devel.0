From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:34 +0000 (GMT)
Subject: main - aux: add corrupt_dev
Message-ID: <20230421125334.625783858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c331a3b1da280f78aefcfc8dad82eb042022bc84
Commit:        c331a3b1da280f78aefcfc8dad82eb042022bc84
Parent:        11562bcc6b9dc09eb0c5bccb69a7741dec9e626b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 01:43:13 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

aux: add corrupt_dev

Add function to corrupt some bytes in give file path presenting
a device.  1st. patern in just once replaced with 2nd. pattern.

Usable to simulate some bit corruption for integrity devices.
---
 test/lib/aux.sh | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3ab599f60..33710a007 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -952,6 +952,25 @@ clear_devs() {
 	done
 }
 
+#
+# corrupt device content
+# $1  file_path
+# $2  string/pattern search for curruption
+# $3  string/pattern replacing/corruptiong
+corrupt_dev() {
+	local a
+
+	# search for string on a file
+	# Note: returned string may possibly start with other ASCII chars
+	# a[0] is position in file,  a[1] is the actual string
+	a=( $(strings -t d -n 64 "$1" | grep -m 1 "$2") ) || true
+
+	test -n "${a[0]-}" || return 0
+
+	# Seek for the sequence and replace it with corruption pattern
+	echo -n "${a[1]/$2/$3}" | dd of="$1" bs=1 oseek="${a[0]}" conv=fdatasync
+}
+
 prepare_backing_dev() {
 	local size=${1=32}
 	shift

