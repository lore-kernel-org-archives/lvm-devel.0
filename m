From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  1 Nov 2010 13:53:52 +0100
Subject: [PATCH 2/3] Document fsadm script return codes
In-Reply-To: <cover.1288614451.git.zkabelac@redhat.com>
References: <cover.1288614451.git.zkabelac@redhat.com>
Message-ID: <2f15fa5683e6ed315f3a529499e0e2e1ead30866.1288614451.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/fsadm.8.in |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 40e6971..fe3d8d3 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -37,6 +37,12 @@ It tries to use the same API for \fBext2/ext3/ext4\fR,
 or an absolute size using a suffix (in powers of 1024).
 If new_size is not supplied, the whole device is used.
 
+.SH "DIAGNOSTIC"
+Exit status is normally 0. If an error occurs, exit status is 1.
+If a user break occurs, exit status is 2. For check operation requested 
+for mounted filesystem which does not support online filesystem check, 
+exit status is 3.
+
 .SH "EXAMPLES"
 "fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the filesystem
 on logical volume /dev/vg/test. If /dev/vg/test contains ext2/ext3/ext4
-- 
1.7.3.2


