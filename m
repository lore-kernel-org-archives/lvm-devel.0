From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:19 +0000 (UTC)
Subject: master - tests: resume devices on background
Message-ID: <20121202170219.271E9A0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dc6ba8309300b576f56e28dc71fba760b3e52df
Commit:        0dc6ba8309300b576f56e28dc71fba760b3e52df
Parent:        9ec474f38aac948a3fb2cb572af9a756b0ac585d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 17:39:36 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:55:49 2012 +0100

tests: resume devices on background

Since some devices may need correct order of their resuming,
resume then all on background and wait for finish.
---
 test/lib/aux.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7c0c189..e3dfdd9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -98,9 +98,11 @@ teardown_devs_prefixed() {
 	# Resume suspended devices first
 	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
 		echo "dmsetup resume \"${dm#Suspended:}\""
-		dmsetup resume "${dm#Suspended:}" || true
+		dmsetup resume "${dm#Suspended:}" &
 	done
 
+	wait
+
 	local mounts=( $(grep "$prefix" /proc/mounts | cut -d' ' -f1) )
 	if test ${#mounts[@]} -gt 0; then
 		test "$stray" -eq 0 || echo "Removing stray mounted devices containing $prefix: ${mounts[@]}"


