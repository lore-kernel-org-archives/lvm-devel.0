From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:18 +0000 (UTC)
Subject: dev-dct-process-latest - libdm: finish the comment
Message-ID: <20140922153818.64F4E60EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30e0c0d863ed64b0ec74af6b4c0c0bfac39fccf4
Commit:        30e0c0d863ed64b0ec74af6b4c0c0bfac39fccf4
Parent:        5895657b5941f78969ab0c1a97cade5084c95166
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 12 15:35:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 12 15:35:57 2014 +0200

libdm: finish the comment

---
 libdm/ioctl/libdm-iface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index fb9bafd..c308fd2 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -306,7 +306,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 /*
  * If require_module_loaded=0, caller is responsible to check
  * whether _dm_device_major or _dm_bitset is really set. If
- * it's not, it means
+ * it's not, it means the module is not loaded.
  */
 static int _create_dm_bitset(int require_module_loaded)
 {


