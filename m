From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Mar 2016 21:41:23 +0000 (UTC)
Subject: master - libdm: Move _skip_fields within file.
Message-ID: <20160322214123.1C25261057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf393466976a226faba924c6d14fa04bd7b37c89
Commit:        cf393466976a226faba924c6d14fa04bd7b37c89
Parent:        65d2d66d02133fc6df1baba74a7fe0883ed2a6e0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 22 19:27:34 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 22 19:35:14 2016 +0000

libdm: Move _skip_fields within file.

---
 libdm/libdm-targets.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index fd74336..8a8a328 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -55,6 +55,18 @@ int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 }
 
 /*
+ * Skip nr fields each delimited by a single space.
+ * FIXME Don't assume single space.
+ */
+static const char *_skip_fields(const char *p, unsigned nr)
+{
+	while (p && nr-- && (p = strchr(p, ' ')))
+		p++;
+
+	return p;
+}
+
+/*
  * Various RAID status versions include:
  * Versions < 1.5.0 (4 fields):
  *   <raid_type> <#devs> <health_str> <sync_ratio>
@@ -133,17 +145,6 @@ bad:
 }
 
 /*
- * Skip nr fields delimited by a single space.
- */
-static const char *_skip_fields(const char *p, unsigned nr)
-{
-	while (p && nr-- && (p = strchr(p, ' ')))
-		p++;
-
-	return p;
-}
-
-/*
  * <metadata block size> <#used metadata blocks>/<#total metadata blocks>
  * <cache block size> <#used cache blocks>/<#total cache blocks>
  * <#read hits> <#read misses> <#write hits> <#write misses>


