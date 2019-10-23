From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 23 Oct 2019 04:02:37 -0400
Subject: master - build: make generate
Message-ID: <201910230802.x9N82bNB012295@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e3c78a6b0285448ca1f96567bc25d8013e97b45
Commit:        3e3c78a6b0285448ca1f96567bc25d8013e97b45
Parent:        570676488516b60ea3132b5010e7aef5d5cb1549
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 23 09:51:07 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 23 09:51:07 2019 +0200

build: make generate

---
 conf/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 91ce5be..05b0857 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -621,7 +621,7 @@ allocation {
 	# Each additional thread after the first will use an additional 18MiB of RAM,
 	# plus 1.12 MiB of RAM per megabyte of configured read cache size.
 	# This configuration option has an automatic default value.
-	# vdo_bio_threads = 1
+	# vdo_bio_threads = 4
 
 	# Configuration option allocation/vdo_bio_rotation.
 	# Specifies the number of I/O operations to enqueue for each bio-submission


