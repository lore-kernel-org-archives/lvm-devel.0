From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 22:58:28 +0000 (UTC)
Subject: master - dmevent: fix referencing
Message-ID: <20151026225828.6E19360C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b702d677477ff6b37678fe2b6c38969792c09359
Commit:        b702d677477ff6b37678fe2b6c38969792c09359
Parent:        44ba862674c995e2ed297714d3aa2b2dbd731ad1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 23:29:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 23:31:23 2015 +0100

dmevent: fix referencing

Plugin increments DSO refcounter in _alloc_thread_status().
---
 daemons/dmeventd/dmeventd.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b5f1be3..d6accbf 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -296,7 +296,6 @@ static struct dso_data *_lookup_dso(struct message_data *data)
 
 	dm_list_iterate_items(dso_data, &_dso_registry)
 		if (!strcmp(data->dso_name, dso_data->dso_name)) {
-			_lib_get(dso_data);
 			ret = dso_data;
 			break;
 		}


