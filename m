From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:49 +0200
Subject: [PATCH 15/22] Replicator: new args
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <5d69de1dd548f465e6c551b69b6488a4ce6272dd.1278505885.git.zkabelac@redhat.com>
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
index a23c46c..78f2177 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -69,6 +69,16 @@ arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
+arg(replicator_ARG, '\0', "replicator", string_arg, 0)
+arg(replicatordev_ARG, '\0', "replicatordev", NULL, 0)
+arg(replicatorsynclog_ARG, '\0', "replicatorsynclog", string_arg, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", string_arg, 0)
+arg(site_ARG, '\0', "site", site_arg, 0)
+arg(fallbehinddata_ARG, '\0', "fallbehinddata", size_mb_arg, 0)
+arg(fallbehindios_ARG, '\0', "fallbehindios", int_arg, 0)
+arg(fallbehindtimeout_ARG, '\0', "fallbehindtimeout", int_arg, 0)
+arg(sitemode_ARG, '\0', "sitemode", sitemode_arg, 0)
+arg(remotevg_ARG, '\0', "remotevg", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
-- 
1.7.1.1


