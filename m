From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 25 May 2009 14:19:15 +0200
Subject: [PATCH 6/9] Udev integration: add lvmsplit command for dmsetup
Message-ID: <4A1A8CC3.2000809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adds lvmsplit command for dmsetup that can split-up given DM name into
its VG/LV/LAYER constituents. No change in here, too...

Peter


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8db38b0..f9551d9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -746,6 +746,24 @@ static int _udevnotify(int argc, char **argv, void *data __attribute((unused)))
 	return dm_udev_notif_sem_dec(cookie);
 }
 
+static int _lvmsplit(int argc, char **argv, void *data __attribute((unused)))
+{
+	int r = 1;
+
+	struct dmsetup_report_obj obj;
+
+	obj.task = NULL;
+	obj.info = NULL;
+	obj.deps_task = NULL;
+	obj.tree_node = NULL;
+	obj.split_name = _get_split_name("LVM-", argv[1]);
+
+	r = dm_report_object(_report, &obj);
+	_destroy_split_name(obj.split_name);
+
+	return r;
+}
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -2146,6 +2164,7 @@ FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_
 #undef FIELD_F
 
 static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
+static const char *lvmsplit_report_options = "vg_name,lv_name,lv_layer";
 
 static int _report_init(struct command *c)
 {
@@ -2158,6 +2177,9 @@ static int _report_init(struct command *c)
 	size_t len = 0;
 	int r = 0;
 
+	if (!strcmp(c->name, "lvmsplit"))
+		options = (char *) lvmsplit_report_options;
+
 	/* emulate old dmsetup behaviour */
 	if (_switches[NOHEADINGS_ARG]) {
 		separator = ":";
@@ -2295,6 +2317,7 @@ static struct command _commands[] = {
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
 	{"udevnotify", "<cookie>", 1, 1, _udevnotify},
+	{"lvmsplit", "<dev_name>", 1, 1, _lvmsplit},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},
@@ -2918,6 +2941,9 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
+	if (!_switches[COLS_ARG] && !strcmp(c->name, "lvmsplit"))
+		_switches[COLS_ARG]++;
+
 	if (_switches[COLS_ARG] && !_report_init(c))
 		goto out;
 


