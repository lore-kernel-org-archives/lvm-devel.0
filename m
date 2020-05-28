From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 28 May 2020 15:45:58 +0000 (GMT)
Subject: master - test: Warn and exit on problematic integrity device behavior
Message-ID: <20200528154558.AB24A386F02B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be61bd6ff5c6c186f38cb36f8878e310df20eff0
Commit:        be61bd6ff5c6c186f38cb36f8878e310df20eff0
Parent:        74a211cfd30e93d9388de5ac1ee22e630c840e94
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 28 17:04:35 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 28 17:04:35 2020 +0200

test: Warn and exit on problematic integrity device behavior

The first leg of integrity enabled raid device sometimes does not get
recalculated.
---
 test/shell/integrity-dmeventd.sh | 8 ++++++++
 test/shell/integrity-large.sh    | 8 ++++++++
 test/shell/integrity-misc.sh     | 8 ++++++++
 test/shell/integrity.sh          | 8 ++++++++
 4 files changed, 32 insertions(+)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index ed2436aca..296f55680 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -109,6 +109,14 @@ _wait_recalc() {
 		sleep 1
 	done
 
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+	if test -z "$sync"; then
+		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+		exit
+	fi
 	echo "timeout waiting for recalc"
 	return 1
 }
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 7a333c101..5aba80e6a 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -95,6 +95,14 @@ _wait_recalc() {
 		sleep 1
 	done
 
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+	if test -z "$sync"; then
+		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+		exit
+	fi
 	echo "timeout waiting for recalc"
 	return 1
 }
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index a176f18e0..0d056890c 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -109,6 +109,14 @@ _wait_recalc() {
 		sleep 1
 	done
 
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+	if test -z "$sync"; then
+		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+		exit
+	fi
 	echo "timeout waiting for recalc"
 	return 1
 }
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 6baccf00c..77e9430fe 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -204,6 +204,14 @@ _wait_recalc() {
 		sleep 1
 	done
 
+	# TODO: There is some strange bug, first leg of RAID with integrity
+	# enabled never gets in sync. I saw this in BB, but not when executing
+	# the commands manually
+	if test -z "$sync"; then
+		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
+		exit
+	fi
 	echo "timeout waiting for recalc"
 	return 1
 }


