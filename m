From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 23 Mar 2017 19:13:28 -0400
Subject: master - libdm: typo
Message-ID: <201703232313.v2NNDSSx025996@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe3b9bb7d47ef168c16cc35e306a41cbb38e869c
Commit:        fe3b9bb7d47ef168c16cc35e306a41cbb38e869c
Parent:        6471bb2c41cf0e692a8fe7ea00033327359d42fc
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 00:12:41 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 00:12:41 2017 +0100

libdm: typo

---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 9bc7674..3551592 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2378,7 +2378,7 @@ static int _get_params_count(uint64_t *bits)
 /*
  * Get target version (major, minor and patchlevel) for @target_name
  *
- * FIXEM: this function is derived from liblvm.
+ * FIXME: this function is derived from liblvm.
  *        Integrate with move of liblvm functions
  *        to libdm in future library layer purge
  *        (e.g. expose as API dm_target_version()?)


