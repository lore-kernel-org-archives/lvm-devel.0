From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 17:03:57 +0000 (UTC)
Subject: master - lvmetad: Add fn to scan only foreign VGs.
Message-ID: <20150223170357.9DEA96078D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48478363109b1ea23a9f0acae8dbfd838cf925c6
Commit:        48478363109b1ea23a9f0acae8dbfd838cf925c6
Parent:        42ba7974c5e85f3b86807dacaf5f70a722475b52
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 17:03:03 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 17:03:03 2015 +0000

lvmetad: Add fn to scan only foreign VGs.

Not implemented yet - just a wrapper.
---
 lib/cache/lvmetad.c |    8 ++++++++
 lib/cache/lvmetad.h |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 20302c1..aad4423 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1031,3 +1031,11 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	return r;
 }
 
+/* 
+ * FIXME Implement this function, skipping PVs known to belong to local or clustered,
+ * non-exported VGs.
+ */
+int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler)
+{
+	return lvmetad_pvscan_all_devs(cmd, handler);
+}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 2cd738e..4d6f107 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -156,6 +156,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler);
 
 int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler);
+int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -181,6 +182,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
 #    define lvmetad_pvscan_single(cmd, dev, handler)	(0)
 #    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
+#    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


