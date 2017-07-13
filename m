From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Jul 2017 15:12:54 -0400
Subject: master - tests: add some delay after dmsetup
Message-ID: <201707131912.v6DJCsZf013566@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=490e6e9ef1bbc30dff81873e9eeb99924688004e
Commit:        490e6e9ef1bbc30dff81873e9eeb99924688004e
Parent:        5027c3c7eea0791a9a80b0622b43c8a493e2a8a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 13 21:06:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 13 21:11:16 2017 +0200

tests: add some delay after dmsetup

When we want to squash as much device as possible,
it's better to give it some delay, so devices have
some time to release it's resouces for next removal.

Also drop surrounding cookie processing and let each
dmsetup call run on its own.
---
 test/lib/aux.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a8b6bea..9e0ca2c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -416,13 +416,12 @@ teardown_devs_prefixed() {
 	#local listdevs=( $(dm_info name,open --sort open,name | grep "$prefix.*:0") )
 	#dmsetup remove --deferred ${listdevs[@]%%:0} || touch REMOVE_FAILED
 
-	init_udev_transaction
 	for dm in $(dm_info name --sort open,name | grep "$prefix"); do
 		dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &
 		need_udev_wait=1
+		sleep 1 # give 'dmsetup' some time to proceed with removal
 	done
 	wait
-	finish_udev_transaction
 	test "$need_udev_wait" -eq 0 || udev_wait
 
 	if test -f REMOVE_FAILED; then
@@ -1214,7 +1213,7 @@ EOF
 	local last_sec
 
 	# read sequential list and put into associative array
-	while IFS=$IFS_NL read -r v; do
+	while IFS= read -r v; do
 		CONF["${v%%[={ ]*}"]=${v#*/}
 	done < "$config_values"
 


