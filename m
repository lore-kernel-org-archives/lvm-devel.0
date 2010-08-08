From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:28 +0200
Subject: [PATCH 16/25] Replicator: new args
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <f3f2146a9ffb5b428ba2a58dab94168a49c3b778.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/args.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index a23c46c..0b8f436 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -69,6 +69,16 @@ arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
+arg(fallbehindios_ARG, '\0', "fallbehindios", int_arg, 0)
+arg(fallbehindsize_ARG, '\0', "fallbehindsize", size_mb_arg, 0)
+arg(fallbehindtimeout_ARG, '\0', "fallbehindtimeout", timeout_arg, 0)
+arg(remotevg_ARG, '\0', "remotevg", string_arg, 0)
+arg(replicated_ARG, '\0', "replicated", NULL, 0)
+arg(replicator_ARG, '\0', "replicator", NULL, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", string_arg, 0)
+arg(replicatorsynclog_ARG, '\0', "replicatorsynclog", string_arg, 0)
+arg(site_ARG, '\0', "site", site_arg, 0)
+arg(sitepolicy_ARG, '\0', "sitepolicy", sitepolicy_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
-- 
1.7.2.1


