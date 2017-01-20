From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:03:57 +0000 (UTC)
Subject: master - cleanup: update config doc
Message-ID: <20170120230357.2E60B60D79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee754500dbb3787b1b9339e59dc4335a9b6c58cd
Commit:        ee754500dbb3787b1b9339e59dc4335a9b6c58cd
Parent:        f8234d6e5f4f82690da61abf03f93ddfb5cff467
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 22:33:07 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:52:40 2017 +0100

cleanup: update config doc

---
 conf/example.conf.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index c3defe5..91d7072 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1156,7 +1156,8 @@ activation {
 	# Configuration option activation/missing_stripe_filler.
 	# Method to fill missing stripes when activating an incomplete LV.
 	# Using 'error' will make inaccessible parts of the device return I/O
-	# errors on access. You can instead use a device path, in which case,
+	# errors on access. Using 'zero' will return success (and zero) on I/O
+	# You can instead use a device path, in which case,
 	# that device will be used in place of missing stripes. Using anything
 	# other than 'error' with mirrored or snapshotted volumes is likely to
 	# result in data corruption.


