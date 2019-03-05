From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:22 -0500
Subject: stable-2.02 - cov: mark warning as expected one
Message-ID: <201903051353.x25DrMcD006715@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93ac80037aefb1f57c7996db3ccfe440b6bc8308
Commit:        93ac80037aefb1f57c7996db3ccfe440b6bc8308
Parent:        c9e5e6800c3225c9eb6cd54f143624c20eda44be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:44:13 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:16:33 2019 +0100

cov: mark warning as expected one

(cherry picked from commit 9238b972c543a83fbd553cc44a916608809cfc53)

Conflicts:
	base/data-struct/radix-tree-adaptive.c
	device_mapper/libdm-file.c
---
 libdm/libdm-file.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index e7416f1..5735642 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -221,6 +221,8 @@ retry_fcntl:
 		goto fail_close_unlink;
 	}
 
+	/* coverity[leaked_handle] intentional leak of fd handle here  */
+
 	return 1;
 
 fail_close_unlink:


