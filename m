From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:31 +0000 (UTC)
Subject: master - cleanup: order ac members
Message-ID: <20160114103531.47E2060DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=278c5509ee88b6384e0ccdb8b8da994b020ffe75
Commit:        278c5509ee88b6384e0ccdb8b8da994b020ffe75
Parent:        c9a813bff8828e379f9be963a49a9201a3484ec6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 14 11:21:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: order ac members

---
 lib/metadata/metadata-exported.h |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8785f99..a118fa8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -574,17 +574,16 @@ struct lvresize_params {
 
 	/* FIXME Deal with meaningless 'ac' */
 	/* Arg counts & values */
+	alloc_policy_t ac_alloc;
+	unsigned ac_force;
+	unsigned ac_mirrors;
+	uint32_t ac_mirrors_value;
+	unsigned ac_no_sync;
 	unsigned ac_policy;
 	unsigned ac_stripes;
 	uint32_t ac_stripes_value;
-	unsigned ac_mirrors;
-	uint32_t ac_mirrors_value;
 	unsigned ac_stripesize;
 	uint64_t ac_stripesize_value;
-	alloc_policy_t ac_alloc;
-	unsigned ac_no_sync;
-	unsigned ac_force;
-
 	const char *ac_type;
 };
 


