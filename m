From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Jul 2013 13:46:05 +0000 (UTC)
Subject: master - tests: add profileconf fn to generate profiles
Message-ID: <20130730134605.CDAEF60EDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba1a8878d05e3753d9ae5a98e51afac71f078fc9
Commit:        ba1a8878d05e3753d9ae5a98e51afac71f078fc9
Parent:        b6bfddcd0a830d0c9312bc3ab906cb3d1b7a6dd9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 30 15:44:15 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 30 15:44:15 2013 +0200

tests: add profileconf fn to generate profiles

profileconf <profile_name> <config> ...
---
 test/lib/aux.sh |   44 +++++++++++++++++++++++++++++++++-----------
 1 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f481db5..d61f17d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -476,15 +476,24 @@ unhide_dev() {
 	lvmconf "$filter"
 }
 
-lvmconf() {
+generate_config() {
+	if test -n "$profile_name"; then
+		config_values=PROFILE_VALUES_$profile_name
+		config=PROFILE_$profile_name
+		touch $config_values
+	else
+		config_values=CONFIG_VALUES
+		config=CONFIG
+	fi
+
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
 	if test "$DM_DEV_DIR" = "/dev"; then
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0}
 	else
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-1}
 	fi
-	test -f CONFIG_VALUES || {
-            cat > CONFIG_VALUES <<-EOF
+	test -f $config_values || {
+            cat > $config_values <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
@@ -523,23 +532,36 @@ EOF
 
 	local v
 	for v in "$@"; do
-	    echo "$v" >> CONFIG_VALUES
+	    echo "$v" >> $config_values
 	done
 
-	rm -f CONFIG
+	rm -f $config
 	local s
-	for s in $(cat CONFIG_VALUES | cut -f1 -d/ | sort | uniq); do
-		echo "$s {" >> CONFIG
+	for s in $(cat $config_values | cut -f1 -d/ | sort | uniq); do
+		echo "$s {" >> $config
 		local k
-		for k in $(grep ^"$s"/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-			grep "^$k" CONFIG_VALUES | tail -n 1 | sed -e "s,^$s/,	  ," >> CONFIG
+		for k in $(grep ^"$s"/ $config_values | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
+			grep "^$k" $config_values | tail -n 1 | sed -e "s,^$s/,	  ," >> $config
 		done
-		echo "}" >> CONFIG
-		echo >> CONFIG
+		echo "}" >> $config
+		echo >> $config
 	done
+}
+
+lvmconf() {
+	unset profile_name
+	generate_config "$@"
 	mv -f CONFIG etc/lvm.conf
 }
 
+profileconf() {
+	profile_name="$1"
+	shift
+	generate_config "$@"
+	test -d etc/profile || mkdir etc/profile
+	mv -f PROFILE_$profile_name etc/profile/$profile_name.profile
+}
+
 apitest() {
 	local t=$1
 	shift


