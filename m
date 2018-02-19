From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Feb 2018 10:46:31 -0500
Subject: master - tests: correct usage of pipe
Message-ID: <201802191546.w1JFkVbF026242@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e5305f630be818e677572e4c43d2c728a89f54f
Commit:        8e5305f630be818e677572e4c43d2c728a89f54f
Parent:        e7f1329cae118ccbfded213eee4895d99d79120b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 17 11:24:32 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 19 16:45:10 2018 +0100

tests: correct usage of pipe

This is somewhat tricky - for test suite we keep using
'set -e -o pipefail'  - the effect here is - we get error report
from any 'failing' command in whole pipeline - thus when something
like this:   'lvs | head -1'  is used - and  'head' finishes before
lead 'lvs' is done - it recieves SIGPIPE and exits with error,
and somewhat misleading gets occasionally reported depending
of speed of commands.

For this case we have to avoid using standard pipes and rather
switch to using streamed results with temporary output file.
This is all nicely handled with bash feature '< <()'.

For more info:
https://stackoverflow.com/questions/41516177/bash-zcat-head-causes-pipefail
---
 test/lib/get.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index e7139dc..afc10bc 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -47,7 +47,7 @@ lv_field() {
 
 lv_first_seg_field() {
 	local r
-	r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1" | head -1)
+	r=$(head -1 < <(lvs --config 'log{prefix=""}' --unbuffered --noheadings -o "$2" "${@:3}" "$1"))
 	trim_ "$r"
 }
 
@@ -74,7 +74,7 @@ lv_field_lv_() {
 lv_tree_devices_() {
 	local lv="$1/$2"
 	local type
-	type=$(lv_field "$lv" segtype -a --unbuffered | head -n 1)
+	type=$(lv_first_seg_field "$lv" segtype -a)
 	#local orig
 	#orig=$(lv_field_lv_ "$lv" origin)
 	# FIXME: should we count in also origins ?


