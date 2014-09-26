From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 26 Sep 2014 15:38:03 -0500
Subject: [PATCH] man: Include max PE size in vgcreate
Message-ID: <1411763883-16107-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 man/vgcreate.8.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index bcfbcfc..050c369 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -121,7 +121,8 @@ default of 4 MiB leads to a maximum logical volume size of around 256GiB.
 
 If the volume group metadata uses lvm2 format those restrictions do not apply,
 but having a large number of extents will slow down the tools but have no
-impact on I/O performance to the logical volume.  The smallest PE is 1KiB
+impact on I/O performance to the logical volume.  The smallest PE is 1KiB, the
+largest PE is 4GiB.
 
 The 2.4 kernel has a limitation of 2TiB per block device.
 
-- 
1.8.2.1


