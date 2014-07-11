From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:35 +0000 (UTC)
Subject: master - cleanup: move merge option
Message-ID: <20140711113435.11EE960EC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de1ee0bc52255987f3b21819a55c0ef9ddf261bb
Commit:        de1ee0bc52255987f3b21819a55c0ef9ddf261bb
Parent:        d5d883d91ba132bd601fb27d44191d3a9c9f64f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 9 17:22:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:21 2014 +0200

cleanup: move merge option

Put long --merge option into section with long options.
---
 tools/args.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 9632478..dc467d2 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -59,6 +59,7 @@ arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
 arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE)
 arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(use_policies_ARG, '\0', "use-policies", NULL, 0)
+arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
@@ -152,7 +153,6 @@ arg(list_ARG, 'l', "list", NULL, 0)
 arg(size_ARG, 'L', "size", size_mb_arg, 0)
 arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
-arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE)
 arg(setactivationskip_ARG, 'k', "setactivationskip", yes_no_arg, 0)
 arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", NULL, 0)


