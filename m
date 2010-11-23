From: Dave Wysochanski <wysochanski@pobox.com>
Date: Tue, 23 Nov 2010 00:01:10 -0500
Subject: [PATCH 2/2] Update interactive tests to display lvm_vg_open errno code.
In-Reply-To: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
References: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290488470-21743-3-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Show errno code if lvm_vg_open() fails.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 test/api/test.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index f19268f..b1b0d61 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -349,7 +349,8 @@ static void _vg_open(char **argv, int argc, lvm_t libh)
 	else
 		vg = lvm_vg_open(libh, argv[1], argv[2], 0);
 	if (!vg || !lvm_vg_get_name(vg)) {
-		printf("Error opening %s\n", argv[1]);
+		printf("Error opening %s, errno = %d\n",
+		       argv[1], lvm_errno(libh));
 		return;
 	}
 
-- 
1.7.2.2


