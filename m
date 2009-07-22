From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 14:36:06 -0400
Subject: [PATCH 2/2] Add a couple lvm_vg_open() calls to vgtest.c.
In-Reply-To: <1248287766-11552-2-git-send-email-dwysocha@redhat.com>
References: <1248287766-11552-1-git-send-email-dwysocha@redhat.com>
	<1248287766-11552-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1248287766-11552-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/vgtest.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index 305914d..f6ede32 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -74,6 +74,20 @@ int main(int argc, char *argv[])
 		goto bad;
 	}
 
+	printf("Closing VG %s\n", vg_name);
+	if (!lvm_vg_close(vg))
+		goto bad;
+	printf("Re-opening VG %s for reading\n", vg_name);
+	vg = lvm_vg_open(handle, vg_name, "r", 0);
+	if (!vg)
+		goto bad;
+	printf("Closing VG %s\n", vg_name);
+	if (!lvm_vg_close(vg))
+		goto bad;
+	printf("Re-opening VG %s for writing\n", vg_name);
+	vg = lvm_vg_open(handle, vg_name, "w", 0);
+	if (!vg)
+		goto bad;
 	printf("Removing VG %s from system\n", vg_name);
 	status = lvm_vg_remove(vg);
 	if (lvm_errno(handle)) {
-- 
1.6.0.6


