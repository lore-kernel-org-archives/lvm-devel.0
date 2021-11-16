From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Nov 2021 20:34:23 +0000 (GMT)
Subject: main - tests pv-ext-flags: work with devices file
Message-ID: <20211116203423.A27783857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c71aa751048f99f4b599a01e7376d8ba951f793
Commit:        5c71aa751048f99f4b599a01e7376d8ba951f793
Parent:        5c4ce4669eb8d8cacc095bd70871c13a4042e5af
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 16 14:21:07 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 16 14:29:22 2021 -0600

tests pv-ext-flags: work with devices file

---
 test/shell/pv-ext-flags.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index 3e6bcff76..ae4d6b7ff 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -57,9 +57,11 @@ dd if="$dev1" of=dev1_backup bs=1M
 
 # pvcreate and pvremove can be forced even if the PV is marked as used
 pvremove -ff -y "$dev1"
+lvmdevices --deldev "$dev1" || true
 dd if=dev1_backup of="$dev1" bs=1M
 pvcreate -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
+lvmdevices --adddev "$dev1" || true
 
 # prepare a VG with $dev1 and $dev both having 1 MDA
 aux enable_dev "$dev2"
@@ -116,9 +118,11 @@ dd if="$dev1" of=dev1_backup bs=1M
 
 # pvcreate and pvremove can be forced even if the PV is marked as used
 pvremove -ff -y "$dev1"
+lvmdevices --deldev "$dev1" || true
 dd if=dev1_backup of="$dev1" bs=1M
 pvcreate -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
+lvmdevices --adddev "$dev1" || true
 
 # prepare a VG with $dev1 and $dev both having 1 MDA
 aux enable_dev "$dev2"


