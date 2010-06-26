From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:08 -0400
Subject: [PATCH 37/38] Update example.conf.in to describe vgmetadatacopies.
In-Reply-To: <1277520789-6808-37-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-33-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-34-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-35-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-36-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-37-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-38-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update example.conf to note the string value.  Special care
must be taken with the string and numeric value - the numbers
must be enclosed in "'s, so this is noted in the comments.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 doc/example.conf.in |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 5318571..5b1f12f 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -456,6 +456,19 @@ activation {
 
     # pvmetadatacopies = 1
 
+    # Default number of copies of metadata to hold on each VG.
+    # If set to a non-zero value, LVM automatically manages the PV
+    # 'metadataignore' flags (see pvchange) to achieve the requested
+    # copies of metadata.  It not an error to set a value larger than
+    # the sum of all metadata areas on all physical volumes.  This value
+    # can be overridden on the command line of various commands. The
+    # default value of "unmanaged" indicates that LVM should not
+    # automatically manage the 'metadataignore' flags.  Note that
+    # this is a string value, so any numbers must be enclosed in '"'s,
+    # for example, vgmetadatacopies = "5".
+
+    # vgmetadatacopies = "unmanaged"
+
     # Approximate default size of on-disk metadata areas in sectors.
     # You should increase this if you have large volume groups or
     # you want to retain a large on-disk history of your metadata changes.
-- 
1.6.0.6


