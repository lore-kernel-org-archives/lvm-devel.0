From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:37 +0000 (UTC)
Subject: master - cleanup: validate pointers
Message-ID: <20141113165337.EB7676105D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=428b9fcd87d1c79cd4349c884a68de7ccac51981
Commit:        428b9fcd87d1c79cd4349c884a68de7ccac51981
Parent:        7278556c768ae418b03873bd5d9e921e13ce79e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 17:40:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:49:42 2014 +0100

cleanup: validate pointers

Mostly on almost impossible to happen paths - but stay safe.
---
 lib/activate/dev_manager.c |    3 ++-
 lib/report/report.c        |    4 +++-
 tools/dmsetup.c            |   11 +++++++----
 tools/pvresize.c           |    4 ++++
 4 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 32abde7..44b273d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -131,7 +131,8 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	if (strcmp(target_name, "cache"))
 		return 1;
 
-	segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name);
+	if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
+		return_0;
 
 	if (segtype != seg_status->seg->segtype) {
 		log_error(INTERNAL_ERROR "_get_segment_status_from_target_params: "
diff --git a/lib/report/report.c b/lib/report/report.c
index 42355e2..5637d50 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -779,7 +779,9 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_cache_pool(seg)) {
-		cachemode_str = get_cache_pool_cachemode_name(seg);
+		if (!(cachemode_str = get_cache_pool_cachemode_name(seg)))
+			return_0;
+
 		return dm_report_field_string(rh, field, &cachemode_str);
 	}
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f1808c0..4202dbb 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3824,13 +3824,15 @@ int main(int argc, char **argv)
 	}
 
 	if (_switches[HELP_ARG]) {
-		cmd = _find_command("help");
-		goto doit;
+		if ((cmd = _find_command("help")))
+			goto doit;
+		goto unknown;
 	}
 
 	if (_switches[VERSION_ARG]) {
-		cmd = _find_command("version");
-		goto doit;
+		if ((cmd = _find_command("version")))
+			goto doit;
+		goto unknown;
 	}
 
 	if (argc == 0) {
@@ -3839,6 +3841,7 @@ int main(int argc, char **argv)
 	}
 
 	if (!(cmd = _find_command(argv[0]))) {
+unknown:
 		fprintf(stderr, "Unknown command\n");
 		_usage(stderr);
 		goto out;
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 70b564d..631e63e 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -30,6 +30,10 @@ static int _pvresize_single(struct cmd_context *cmd,
 {
 	struct pvresize_params *params = (struct pvresize_params *) handle;
 
+	if (!params) {
+		log_error(INTERNAL_ERROR "Invalid resize params.");
+		return ECMD_FAILED;
+	}
 	params->total++;
 
 	if (!pv_resize_single(cmd, vg, pv, params->new_size))


