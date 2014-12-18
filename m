From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 16:31:23 +0000 (UTC)
Subject: master - report: fix segfault on NULL value hit in cache_settings field
Message-ID: <20141218163123.17E5760EE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57af48d734f1f7aa985424a1e11287a0975077b9
Commit:        57af48d734f1f7aa985424a1e11287a0975077b9
Parent:        da9da0d8c2201c244d06a713134e96d2a26a0db5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 16:12:50 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 17:26:12 2014 +0100

report: fix segfault on NULL value hit in cache_settings field

We have to use empty list, not NULL if we want to denote that the list
has no items. Otherwise, the code further can segfault as it expects
there's always a sane value (= some list), including empty list,
but never NULL.
---
 lib/report/report.c     |   19 +++++++++++++++----
 test/shell/lvs-cache.sh |    3 +++
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 417396c..818e3fd 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -256,16 +256,27 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct dm_config_node *settings;
 	struct dm_list *result;
 	struct _str_list_append_baton baton;
+	struct dm_list dummy_list; /* dummy list to display "nothing" */
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
-	else
-		return _field_set_value(field, "", NULL /* TODO: GET_FIRST_RESERVED_NAME(cache_settings_undef) */);
+	else {
+		dm_list_init(&dummy_list);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+		/* TODO: once we have support for STR_LIST reserved values, replace with:
+		 * return _field_set_value(field,  GET_FIRST_RESERVED_NAME(cache_settings_undef), GET_FIELD_RESERVED_VALUE(cache_settings_undef));
+		 */
+	}
 
 	if (seg->policy_settings)
 		settings = seg->policy_settings->child;
-	else
-		return _field_set_value(field, "", NULL /* TODO: GET_FIRST_RESERVED_NAME(cache_settings_default) */);
+	else {
+		dm_list_init(&dummy_list);
+		return _field_set_string_list(rh, field, &dummy_list, private, 0);
+		/* TODO: once we have support for STR_LIST reserved values, replace with:
+		 * return _field_set_value(field,  GET_FIRST_RESERVED_NAME(cache_settings_undef), GET_FIELD_RESERVED_VALUE(cache_settings_undef));
+		 */
+	}
 
 	if (!(result = str_list_create(mem)))
 		return_0;
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 5108076..08e83bd 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -58,6 +58,9 @@ lvs -o +cache_policy -S 'cache_policy=mq' | not grep foo
 lvs -o +cache_policy -S 'cache_policy=undefined' | not grep corigin
 lvs -o +cache_policy -S 'cache_policy=undefined' | grep foo
 lvs -o +cache_policy -O cache_policy
+lvs -o +cache_settings -S 'cache_settings={migration_threshold=233}' | grep corigin
+lvs -o +cache_settings -S 'cache_settings!={migration_threshold=233}' | grep foo
+lvs -o +cache_policy -O cache_settings
 
 lvremove -f $vg
 


