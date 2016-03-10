From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:00 +0000 (UTC)
Subject: master - libdm: parse more info from cache status
Message-ID: <20160310174000.D547860EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29d1533a497be922dc114524b83e926cbb63c34a
Commit:        29d1533a497be922dc114524b83e926cbb63c34a
Parent:        9918d95490d46dee12768494dcc8afe784dd19c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 9 18:00:57 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:53 2016 +0100

libdm: parse more info from cache status

Parse Fail/Error/need_check/ro status info from cache.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    8 +++++++-
 libdm/libdm-targets.c |   18 ++++++++++++++++++
 3 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4cdd97c..274d1b9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.120 - 
 =================================
+  Improve parsing of cache status and report Fail, Error, needs_check, ro.
 
 Version 1.02.119 - 4th March 2016
 =================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0b7d5ba..ac79a57 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -361,8 +361,14 @@ struct dm_status_cache {
 	char **core_argv;
 
 	char *policy_name;
-	int   policy_argc;
+	int policy_argc;
 	char **policy_argv;
+
+	unsigned error : 1;		/* detected error (switches to fail soon) */
+	unsigned fail : 1;		/* all I/O fails */
+	unsigned needs_check : 1;	/* metadata needs check */
+	unsigned read_only : 1;		/* metadata may not be changed */
+	uint32_t reserved : 28;
 };
 
 int dm_get_status_cache(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 7428eba..bd6e5e2 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -194,6 +194,17 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_cache))))
 		return_0;
 
+	if (strstr(params, "Error")) {
+		s->error = 1;
+		s->fail = 1; /*  This is also I/O fail state */
+		goto out;
+	}
+
+	if (strstr(params, "Fail")) {
+		s->fail = 1;
+		goto out;
+	}
+
 	/* Read in args that have definitive placement */
 	if (sscanf(params,
 		   " %" PRIu32
@@ -258,6 +269,13 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 	     (dm_split_words(str, s->policy_argc, 0, s->policy_argv) != s->policy_argc)))
 		goto bad;
 
+	/* TODO: improve this parser */
+	if (strstr(p, " ro"))
+		s->read_only = 1;
+
+	if (strstr(p, " needs_check"))
+		s->needs_check = 1;
+out:
 	*status = s;
 	return 1;
 


