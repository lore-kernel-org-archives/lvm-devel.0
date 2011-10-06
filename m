From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  6 Oct 2011 11:43:00 +0200
Subject: [PATCH 1/3] Fix core on buggy config file
In-Reply-To: <cover.1317893838.git.zkabelac@redhat.com>
References: <cover.1317893838.git.zkabelac@redhat.com>
Message-ID: <b0b3a5f14ec1b30a83357f76197a3cdea87fbf8b.1317893838.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since fixed within unreleased version - no WHATS_NEW

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-config.c |    6 +++++-
 test/t-000-basic.sh  |    3 +++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index a831936..b9ce7a3 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -170,8 +170,12 @@ void dm_config_destroy(struct dm_config_tree *cft)
  */
 struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft)
 {
-	struct dm_config_tree *second_cft = cft->cascade;
+	struct dm_config_tree *second_cft;
 
+	if (!cft)
+		return NULL;
+
+	second_cft = cft->cascade;
 	cft->cascade = NULL;
 
 	return second_cft;
diff --git a/test/t-000-basic.sh b/test/t-000-basic.sh
index bd7ba69..dbee47c 100755
--- a/test/t-000-basic.sh
+++ b/test/t-000-basic.sh
@@ -23,3 +23,6 @@ diff -u actual expected
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5
 
+# ensure we not crash on buggy in config files
+aux lvmconf 'log/prefix = 1""'
+not lvs
-- 
1.7.6.4


