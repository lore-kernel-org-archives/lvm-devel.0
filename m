From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:20 -0500
Subject: master - cov: mark warning as expected one
Message-ID: <201811051627.wA5GRKRd005418@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9238b972c543a83fbd553cc44a916608809cfc53
Commit:        9238b972c543a83fbd553cc44a916608809cfc53
Parent:        0d934e730ec62d16c4f47dbb0d8e97ed16910786
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:44:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:10:32 2018 +0100

cov: mark warning as expected one

---
 base/data-struct/radix-tree-adaptive.c |    1 +
 device_mapper/libdm-file.c             |    2 ++
 libdm/libdm-file.c                     |    2 ++
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index f8f3322..25dfbee 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -354,6 +354,7 @@ static bool _insert_node16(struct radix_tree *rt, struct value *v, uint8_t *kb,
 			return false;
 
 		n48->nr_entries = 17;
+		/* coverity[bad_memset] intentional use of '0' */
 		memset(n48->keys, 48, sizeof(n48->keys));
 
 		for (i = 0; i < 16; i++) {
diff --git a/device_mapper/libdm-file.c b/device_mapper/libdm-file.c
index 096c796..37c6ce7 100644
--- a/device_mapper/libdm-file.c
+++ b/device_mapper/libdm-file.c
@@ -222,6 +222,8 @@ retry_fcntl:
 		goto fail_close_unlink;
 	}
 
+	/* coverity[leaked_handle] intentional leak of fd handle here  */
+
 	return 1;
 
 fail_close_unlink:
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index fc93dda..290ad32 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -221,6 +221,8 @@ retry_fcntl:
 		goto fail_close_unlink;
 	}
 
+	/* coverity[leaked_handle] intentional leak of fd handle here  */
+
 	return 1;
 
 fail_close_unlink:


