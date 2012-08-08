From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  8 Aug 2012 17:32:56 +0000 (UTC)
Subject: master - RAID: Improve RAID argument handling.
Message-ID: <20120808173256.E9CB83484@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de3b1c4506ff502f00a360a83800f35a31e1b42e
Commit:        de3b1c4506ff502f00a360a83800f35a31e1b42e
Parent:        b61be643701d05bb12e0b2e32085f312a1f121bf
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Aug 8 12:32:27 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Aug 8 12:32:27 2012 -0500

RAID: Improve RAID argument handling.

Disallow '-m' for RAID types that have no mirror component and disallow
'-i' argument for RAID types that have no stripe component.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 25f4a9c..fd741bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 7th August 2012
 =================================
+  Issue error message when arguments do not match specified RAID type.
   Improve documention of allocation policies in lvm.8.
   Increase limit for major:minor to 4095:1048575 when using -My option.
   Add make install_systemd_generators.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 48977d7..da2b925 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -539,6 +539,27 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	}
 
 	/*
+	 * RAID types without a mirror component do not take '-m' arg
+	 */
+	if (!segtype_is_mirrored(lp->segtype) &&
+	    arg_count(cmd, mirrors_ARG)) {
+		log_error("Mirror argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * RAID1 does not take a stripe arg
+	 */
+	if ((lp->stripes > 1) &&
+	    segtype_is_mirrored(lp->segtype) &&
+	    strcmp(lp->segtype->name, "raid10")) {
+		log_error("Stripe argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
 	 * _read_mirror_params is called before _read_raid_params
 	 * and already sets:
 	 *   lp->nosync


