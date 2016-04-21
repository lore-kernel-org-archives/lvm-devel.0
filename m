From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:44 +0000 (UTC)
Subject: master - coverity: avoid using signed types for single bits
Message-ID: <20160421231844.ED305616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0bf55186263de96c0f7377c631d27d9679d4df27
Commit:        0bf55186263de96c0f7377c631d27d9679d4df27
Parent:        412f09ca332c644e08421e289a3e8d54890971ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:54:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:12:34 2016 +0200

coverity: avoid using signed types for single bits

---
 lib/metadata/lv.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index da81419..08fc090 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -94,8 +94,8 @@ struct historical_logical_volume {
 	uint64_t timestamp_removed;
 	struct generic_logical_volume *indirect_origin;
 	struct dm_list indirect_glvs; /* list of struct generic_logical_volume */
-	int checked:1; /* set if this historical LV has been checked for validity */
-	int valid:1;   /* historical LV is valid if there's at least one live LV among ancestors */
+	unsigned checked:1; /* set if this historical LV has been checked for validity */
+	unsigned valid:1;   /* historical LV is valid if there's at least one live LV among ancestors */
 };
 
 struct generic_logical_volume {


