From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:44 +0000 (UTC)
Subject: master - tests: add driver_at_least() to aux.sh
Message-ID: <20160225165144.00C6C60E67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3dae4162293e385083025c85ec0e6307c48eb48e
Commit:        3dae4162293e385083025c85ec0e6307c48eb48e
Parent:        1f8fd5a1522b607255eb8e45572a22de85d6f2ae
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Nov 27 17:55:08 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:58 2016 +0000

tests: add driver_at_least() to aux.sh

Add a function to test whether the running device-mapper driver
version is at least equal to some given version.
---
 test/lib/aux.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cfd3620..e517bc0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1232,6 +1232,21 @@ target_at_least() {
 	}
 }
 
+# Check whether the kernel driver version is greater or equal
+# to the specified version. This can be used to skip tests on
+# kernels where they are known to not be supported.
+#
+# e.g. driver_at_least 4 33
+#
+driver_at_least() {
+	local version=$(dmsetup version | tail -1 2>/dev/null)
+	version=${version##*:}
+	version_at_least "$version" "$@" || {
+		echo "Found driver version $version, but requested $@." >&2
+		return 1
+	}
+}
+
 have_thin() {
 	test "$THIN" = shared -o "$THIN" = internal || {
 		echo "Thin is not built-in." >&2


