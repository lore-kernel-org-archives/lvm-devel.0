From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 23 May 2016 17:05:15 +0000 (UTC)
Subject: master - test: lvmetad-pvscan-filter
Message-ID: <20160523170515.2E73460D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d3efd7ab80f200148f8c133521320642aa9d221
Commit:        3d3efd7ab80f200148f8c133521320642aa9d221
Parent:        9b640c36841e2790731d54a5830dcea8203f9e80
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 5 15:16:38 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 23 12:00:25 2016 -0500

test: lvmetad-pvscan-filter

update for pvscan changes
---
 test/shell/lvmetad-pvscan-filter.sh |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 91bb930..cb3fcdc 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -22,17 +22,35 @@ min=$(($(stat -L --printf=0x%T "$dev2")))
 
 # Filter out device, pvscan should trigger
 # clearing of the device from lvmetad cache.
-aux hide_dev "$dev2"
-pvscan --cache "$dev2" 2>&1 | grep "not found"
+
+# We can't use aux hide_dev here because that
+# changes the global_filter which triggers a
+# token mismatch rescan by subsequent pvscan
+# commands instead of the single-dev scans
+# that are testing here.
+
+mv "$dev2" "$dev2-HIDDEN"
+
+pvscan --cache "$dev2" 2>&1 | tee out || true
+grep "not found" out
+
 # pvscan with --major/--minor does not fail: lvmetad needs to
 # be notified about device removal on REMOVE uevent, hence
 # this should not fail so udev does not grab a "failed" state
 # incorrectly. We notify device addition and removal with
 # exactly the same command "pvscan --cache" - in case of removal,
 # this is detected by nonexistence of the device itself.
-pvscan --cache --major $maj --minor $min 2>&1 | grep "not found"
-aux unhide_dev "$dev2"
 
-pvscan --cache "$dev2" 2>&1 | not grep "not found"
-pvscan --cache --major $maj --minor $min 2>&1 | not grep "not found"
+pvscan --cache --major $maj --minor $min 2>&1 | tee out || true
+grep "not found" out
+
+# aux unhide_dev "$dev2"
+mv "$dev2-HIDDEN" "$dev2"
+
+pvscan --cache "$dev2" 2>&1 | tee out || true
+not grep "not found" out
+
+pvscan --cache --major $maj --minor $min 2>&1 | tee out || true
+not grep "not found" out
+
 pvs | grep "$dev2"


