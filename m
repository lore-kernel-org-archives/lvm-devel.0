From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:18 +0000 (UTC)
Subject: master - tests: add check sysfs_queue
Message-ID: <20150402114118.9EB306023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a6e3838e961fe072bbaafe9f8b073b1c1b0c242
Commit:        7a6e3838e961fe072bbaafe9f8b073b1c1b0c242
Parent:        95dbedb301976e176315a95c34be2f3e71a281f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 12:21:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:41 2015 +0200

tests: add check sysfs_queue

Add check function for content of /sys/block/$1/queue/$2 == $3
---
 test/lib/check.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index add8fb8..12c5e23 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -365,6 +365,14 @@ dev_md5sum() {
 		 die "LV $1/$2 has different MD5 check sum!")
 }
 
+sysfs_queue() {
+	# Verify optimal_io_size
+	local P="/sys/block/$1/queue/$2"
+	test -f "$P" || return 0
+	test "$(< $P)" -eq "$3" || \
+		die "$P = $(< $P) differs from expected value $3!"
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"


