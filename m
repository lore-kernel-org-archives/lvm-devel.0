From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 23 Jun 2016 07:37:59 +0000 (UTC)
Subject: master - filters: add comments about internal filter position in filter chain
Message-ID: <20160623073759.58AA060E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79eaaee50af92d2fd6f6590670787c87b9ce0225
Commit:        79eaaee50af92d2fd6f6590670787c87b9ce0225
Parent:        6513a7a44950ded037e1fb3e974a089b8e5690df
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 23 09:37:51 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 23 09:37:51 2016 +0200

filters: add comments about internal filter position in filter chain

---
 lib/commands/toolcontext.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3ee9410..d263e13 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1166,7 +1166,7 @@ bad:
  * If lvmetad is used, there are three filter chains:
  *
  *   - cmd->lvmetad_filter - the lvmetad filter chain used when scanning devs for lvmetad update:
- *     sysfs filter -> global regex filter -> type filter ->
+ *     sysfs filter -> internal filter -> global regex filter -> type filter ->
  *     usable device filter(FILTER_MODE_PRE_LVMETAD) ->
  *     mpath component filter -> partitioned filter ->
  *     md component filter -> fw raid filter
@@ -1180,7 +1180,7 @@ bad:
  * If lvmetad is not used, there's just one filter chain:
  *
  *   - cmd->filter == cmd->full_filter:
- *     persistent filter -> sysfs filter -> global regex filter ->
+ *     persistent filter -> sysfs filter -> internal filter -> global regex filter ->
  *     regex_filter -> type filter -> usable device filter(FILTER_MODE_NO_LVMETAD) ->
  *     mpath component filter -> partitioned filter -> md component filter -> fw raid filter
  *


