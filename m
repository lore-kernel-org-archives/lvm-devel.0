From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:19 -0400
Subject: [PATCH 10/11] Update test/api/test.c to handle read/write open modes.
In-Reply-To: <1248480500-472-10-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
	<1248480500-472-6-git-send-email-dwysocha@redhat.com>
	<1248480500-472-7-git-send-email-dwysocha@redhat.com>
	<1248480500-472-8-git-send-email-dwysocha@redhat.com>
	<1248480500-472-9-git-send-email-dwysocha@redhat.com>
	<1248480500-472-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index c9500ff..a7d6bc6 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -162,8 +162,10 @@ static void _vg_open(char **argv, int argc, lvm_t libh)
 		printf ("VG already open\n");
 		return;
 	}
-	/* FIXME: allow different open modes */
-	vg = lvm_vg_open(libh, argv[1], "r", 0);
+	if (argc < 3)
+		vg = lvm_vg_open(libh, argv[1], "r", 0);
+	else
+		vg = lvm_vg_open(libh, argv[1], argv[2], 0);
 	if (!vg || !lvm_vg_get_name(vg)) {
 		printf("Error opening %s\n", argv[1]);
 		return;
-- 
1.6.0.6


