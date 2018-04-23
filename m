From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:56:14 -0400
Subject: master - bcache: intercept test mode before write
Message-ID: <201804231356.w3NDuE0j002168@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa833bdd8aa6a3e3557b19fa3877b0eee806df63
Commit:        aa833bdd8aa6a3e3557b19fa3877b0eee806df63
Parent:        9b6a62f9445b104f8b4f14b1ebe8258b360950e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 9 13:57:44 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

bcache: intercept test mode before write

Don't allow writes in test mode.  test mode should be
more sophisticated than just faking writes, and this
should be a last defense for cases where test mode is
not being checked correctly.
---
 lib/label/label.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index c11a040..4b18f56 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -922,6 +922,9 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 {
 	int ret;
 
+	if (test_mode())
+		return true;
+
 	if (!scan_bcache) {
 		if (!dev_open(dev))
 			return false;
@@ -955,6 +958,9 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 {
 	int ret;
 
+	if (test_mode())
+		return true;
+
 	if (!scan_bcache) {
 		if (!dev_open(dev))
 			return false;


