From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 11:31:34 +0000 (UTC)
Subject: master - libdm: fix resource leak in dm_stats_set_alias()
Message-ID: <20160708113134.6E8EC60EEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=059a383cf8d3198ba6c77a18cea09c4a0a40032a
Commit:        059a383cf8d3198ba6c77a18cea09c4a0a40032a
Parent:        5e06b33c51e2b264ad8a48b61f18bf3bff37c992
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Jul 8 10:51:19 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 11:14:29 2016 +0100

libdm: fix resource leak in dm_stats_set_alias()

When we fail to update aux_data the newly allocated group->alias must
be freed before reinstating old_alias.
---
 libdm/libdm-stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e979b34..d89f77a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3106,6 +3106,7 @@ int dm_stats_set_alias(struct dm_stats *dms, uint64_t group_id, const char *alia
 	return 1;
 
 bad:
+	dm_free((char *) group->alias);
 	group->alias = old_alias;
 	return 0;
 }


