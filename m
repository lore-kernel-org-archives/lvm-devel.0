From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Dec 2016 10:24:21 +0000 (UTC)
Subject: master - cov: use unsigned for single bit values
Message-ID: <20161212102421.21E8060C5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48d33e5fb671af16f84d74afab9f86d47ca112fc
Commit:        48d33e5fb671af16f84d74afab9f86d47ca112fc
Parent:        56e4e2ce2ba05990eb4e8ced8a9a966b986f14ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 12 11:21:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 12 11:21:42 2016 +0100

cov: use unsigned for single bit values

Avoid using signed int.
---
 libdm/libdm-report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index ebd2439..93b8774 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -95,8 +95,8 @@ struct report_group_item {
 		uint32_t finished_count;
 	} store;
 	struct report_group_item *parent;
-	int output_done:1;
-	int needs_closing:1;
+	unsigned output_done:1;
+	unsigned needs_closing:1;
 	void *data;
 };
 


