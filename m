From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Dec 2018 09:15:39 -0500
Subject: 2018-06-01-stable - build: make generate
Message-ID: <201812071415.wB7EFdoi012666@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=262a42025ffef8a0ccb02e13d60abf3707d7c832
Commit:        262a42025ffef8a0ccb02e13d60abf3707d7c832
Parent:        d5234e1b7eceeb1eb9ceff9877aea2a39fde1906
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 6 11:12:28 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Dec 7 15:05:50 2018 +0100

build: make generate

---
 conf/example.conf.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4c62aad..e6f3462 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -891,6 +891,11 @@ global {
 	# This configuration option has an automatic default value.
 	# lvdisplay_shows_full_device_path = 0
 
+	# Configuration option global/use_aio.
+	# Use async I/O when reading and writing devices.
+	# This configuration option has an automatic default value.
+	# use_aio = 1
+
 	# Configuration option global/use_lvmetad.
 	# Use lvmetad to cache metadata and reduce disk scanning.
 	# When enabled (and running), lvmetad provides LVM commands with VG


