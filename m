From: Tony Asleson <tasleson@redhat.com>
Date: Mon,  6 Jul 2015 11:46:19 -0500
Subject: [PATCH] Limited example C dbus service and client
Message-ID: <1436201179-20747-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

daemons/lvmdbusd directory contains a sample service written in C (lvmdbusd.c)
and client (example_client.c).  The service and client are using auto generated
code from gdbus-codegen.  This tool uses the api.xml file as input and generates
a header file and implementation file to be used for the API.

This sample service at the moment is limited to:

- Retrieving the VGs/PVs/LVs
- Removing a LV

The service is implemented using the lvm2app API, so functionality in what the
properties contain is limited to what is available in the library.  I choose
the API in this example instead of trying to re-work the existing code as the
dbus bit is more important than showing the lvm bits at the moment.  As this
is a service, the implementation is free to change at will as long as the
API remains the same.

The client shows how to use the object manager to retrieve all the objects in
one shot and to iterate through them.  It also has a monitor mode so that
signals can be seen when objects get created/deleted/updated etc.

I initially tried to use the existing lvm code and integrate with the client
code, but I rejected that approach as the lvm reporting code appears to be
quite tightly coupled with the lvm internals which represent the data.
Thus the sample client code is more of an example on how to get data using
the C dbus API more than fitting it into existing lvm client code.

Disclaimer, this was my first exposure to the C dbus and coding a service &
client so I'm not making any suggestions that it's the best use of the APIs or
the best overall design.  It's just an example.

Note: configure updates were not checked in as the auto updated changes exceed
line length for emailing a patch.

Regards,
Tony

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 Makefile.in                       |    9 +-
 configure.in                      |    5 +
 daemons/Makefile.in               |    6 +-
 daemons/lvmdbusd/Makefile.in      |   43 ++
 daemons/lvmdbusd/api.xml          |  178 +++++++++
 daemons/lvmdbusd/example_client.c |  218 +++++++++++
 daemons/lvmdbusd/lvmdbusd.c       |  765 +++++++++++++++++++++++++++++++++++++
 make.tmpl.in                      |    3 +
 8 files changed, 1222 insertions(+), 5 deletions(-)
 create mode 100644 daemons/lvmdbusd/Makefile.in
 create mode 100644 daemons/lvmdbusd/api.xml
 create mode 100644 daemons/lvmdbusd/example_client.c
 create mode 100644 daemons/lvmdbusd/lvmdbusd.c

diff --git a/Makefile.in b/Makefile.in
index 43a6ed0..0127fc9 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
-SUBDIRS = conf daemons include lib libdaemon libdm man scripts tools
+SUBDIRS = conf include lib libdaemon libdm man scripts tools
 
 ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
@@ -36,14 +36,17 @@ ifeq ("@PYTHON_BINDINGS@", "yes")
   SUBDIRS += python
 endif
 
+# Daemons needs to get built after liblvm for lvmdbusd
+SUBDIRS += daemons
+
 ifeq ($(MAKECMDGOALS),clean)
   SUBDIRS += test
 endif
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = conf include man test scripts \
-    libdaemon lib tools daemons libdm \
-    udev po liblvm python \
+    libdaemon lib tools libdm \
+    udev po liblvm python daemons \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
 tools.distclean: test.distclean
 endif
diff --git a/configure.in b/configure.in
index 86ab98a..adb35c5 100644
--- a/configure.in
+++ b/configure.in
@@ -799,6 +799,8 @@ if test "$BUILDOPENAIS" = yes; then
 	CHECKCPG=yes
 fi
 
+PKG_CHECK_MODULES([GIO], [gio-unix-2.0])
+
 dnl -- Below are checks for libraries common to more than one build.
 
 dnl -- Check confdb library.
@@ -1836,6 +1838,8 @@ AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
+AC_SUBST(GIO_CFLAGS)
+AC_SUBST(GIO_LIBS)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
 AC_SUBST(SNAPSHOTS)
@@ -1896,6 +1900,7 @@ daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
+daemons/lvmdbusd/Makefile
 conf/Makefile
 conf/example.conf
 conf/lvmlocal.conf
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 8a466b3..7321f49 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -15,7 +15,9 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-.PHONY: dmeventd clvmd cmirrord lvmetad lvmpolld
+.PHONY: dmeventd clvmd cmirrord lvmetad lvmpolld lvmdbusd
+
+SUBDIRS += lvmdbusd
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS += clvmd
@@ -41,7 +43,7 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmdbusd
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
new file mode 100644
index 0000000..887b4c4
--- /dev/null
+++ b/daemons/lvmdbusd/Makefile.in
@@ -0,0 +1,43 @@
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = lvmdbusd.c lvm_dbus_generated.c
+
+TARGETS = lvmdbusd example_client
+
+.PHONY: install_lvmdbusd
+
+include $(top_builddir)/make.tmpl
+
+lvm_dbus_generated.c: api.xml
+	gdbus-codegen --generate-c-code lvm_dbus_generated --c-namespace lvm1 \
+	--c-generate-object-manager --interface-prefix com.redhat.lvm1 api.xml
+
+DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
+
+lvmdbusd: lvmdbusd.c lvm_dbus_generated.c
+	$(CC) -I$(top_builddir)/include $(CFLAGS) $(LDFLAGS) $(GIO_CFLAGS) \
+	$(SOURCES) -o $@ $(GIO_LIBS) $(DEPLIBS)
+
+example_client: example_client.c lvm_dbus_generated.c lvm_dbus_generated.h
+	$(CC) $(CFLAGS) $(LDFLAGS) $(GIO_CFLAGS) -o $@ \
+	example_client.c lvm_dbus_generated.c $(GIO_LIBS) $(DEPLIBS)
+
+install_lvmdbusd: lvmdbusd
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
+install_lvm2: install_lvmdbusd
+
+install: install_lvm2
diff --git a/daemons/lvmdbusd/api.xml b/daemons/lvmdbusd/api.xml
new file mode 100644
index 0000000..6d21f55
--- /dev/null
+++ b/daemons/lvmdbusd/api.xml
@@ -0,0 +1,178 @@
+<?xml version="1.0" encoding="utf8"?>
+
+<!--
+This XML was generated from the LVM POC done in python.  Commented out things
+that are not implemented@the moment and that are not available via the
+lvm2app API.  The lvm2app API use is not a requirement for dbus service
+implementation.
+-->
+<node>
+<interface name="com.redhat.lvm1.Manager">
+    <method name="PvCreate">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="device" type="s"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="VgCreate">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="pv_object_paths" type="ao"/>
+      <arg direction="in" name="name" type="s"/>
+    </method>
+</interface>
+<interface name="com.redhat.lvm1.lv">
+    <method name="Move">
+      <arg direction="in" name="move_options" type="a{sv}"/>
+      <arg direction="in" name="pv_src_obj" type="o"/>
+      <arg direction="in" name="pv_source_range" type="(tt)"/>
+      <arg direction="in" name="pv_dest_obj" type="o"/>
+      <arg direction="in" name="pv_dest_range" type="(tt)"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="Remove">
+    </method>
+    <property access="read" name="vg" type="o"/>
+    <property access="read" name="uuid" type="s"/>
+    <property access="read" name="tags" type="as"/>
+    <property access="read" name="size_bytes" type="t"/>
+    <property access="read" name="origin_lv" type="o"/>
+    <property access="read" name="name" type="s"/>
+    <property access="read" name="attr" type="s"/>
+
+	<!--
+	<property access="read" name="pool_lv" type="o"/>
+	<property access="read" name="devices" type="a(oa(tt))"/>
+    <property access="read" name="data_percent" type="i"/>
+	<property access="read" name="path" type="s"/>
+	-->
+
+</interface>
+<interface name="com.redhat.lvm1.pv">
+
+	<!--
+	<method name="AllocationEnabled">
+      <arg direction="in" name="yes" type="b"/>
+    </method>
+    <method name="ReSize">
+      <arg direction="in" name="new_size_bytes" type="t"/>
+    </method>
+	-->
+    <method name="Remove">
+    </method>
+
+    <!--
+	<property access="read" name="allocatable" type="b"/>
+    <property access="read" name="pe_segments" type="a(tt)"/>
+    <property access="read" name="fmt" type="s"/>
+    <property access="read" name="lv" type="a(oa(tt))"/>
+	<property access="read" name="pe_start" type="t"/>
+    <property access="read" name="pe_alloc_count" type="t"/>
+    <property access="read" name="ba_size_bytes" type="t"/>
+	<property access="read" name="pe_count" type="t"/>
+	<property access="read" name="exportable" type="b"/>
+    <property access="read" name="missing" type="b"/>
+    <property access="read" name="tags" type="as"/>
+    <property access="read" name="mda_free_bytes" type="t"/>
+    <property access="read" name="mda_size_bytes" type="t"/>
+	<property access="read" name="used_bytes" type="t"/>
+
+	<property access="read" name="ba_start" type="t"/>
+	-->
+	<property access="read" name="uuid" type="s"/>
+	<property access="read" name="name" type="s"/>
+	<property access="read" name="vg" type="o"/>
+    <property access="read" name="size_bytes" type="t"/>
+	<property access="read" name="dev_size_bytes" type="t"/>
+    <property access="read" name="free_bytes" type="t"/>
+
+</interface>
+<interface name="com.redhat.lvm1.vg">
+    <method name="LvCreateStriped">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="name" type="s"/>
+      <arg direction="in" name="size_bytes" type="t"/>
+      <arg direction="in" name="num_stripes" type="u"/>
+      <arg direction="in" name="stripe_size_kb" type="u"/>
+      <arg direction="in" name="thin_pool" type="b"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="Extend">
+      <arg direction="in" name="pv_object_paths" type="ao"/>
+    </method>
+    <method name="LvCreateMirror">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="name" type="s"/>
+      <arg direction="in" name="size_bytes" type="t"/>
+      <arg direction="in" name="num_copies" type="u"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="Reduce">
+      <arg direction="in" name="missing" type="b"/>
+      <arg direction="in" name="pv_object_paths" type="ao"/>
+    </method>
+    <method name="Remove">
+    </method>
+    <method name="LvCreate">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="name" type="s"/>
+      <arg direction="in" name="size_bytes" type="t"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="LvCreateRaid">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="name" type="s"/>
+      <arg direction="in" name="raid_type" type="s"/>
+      <arg direction="in" name="size_bytes" type="t"/>
+      <arg direction="in" name="num_stripes" type="u"/>
+      <arg direction="in" name="stripe_size_kb" type="u"/>
+      <arg direction="in" name="thin_pool" type="b"/>
+      <arg direction="out" type="o"/>
+    </method>
+    <method name="Change">
+      <arg direction="in" name="change_options" type="a{sv}"/>
+    </method>
+    <method name="LvCreateLinear">
+      <arg direction="in" name="create_options" type="a{sv}"/>
+      <arg direction="in" name="name" type="s"/>
+      <arg direction="in" name="size_bytes" type="t"/>
+      <arg direction="in" name="thin_pool" type="b"/>
+      <arg direction="out" type="o"/>
+    </method>
+
+	<property access="read" name="name" type="s"/>
+	<property access="read" name="uuid" type="s"/>
+	<property access="read" name="seqno" type="t"/>
+	<property access="read" name="partial" type="b"/>
+	<property access="read" name="clustered" type="b"/>
+	<property access="read" name="exportable" type="b"/>
+	<property access="read" name="size_bytes" type="t"/>
+	<property access="read" name="free_bytes" type="t"/>
+	<property access="read" name="extent_size_bytes" type="t"/>
+	<property access="read" name="extent_count" type="t"/>
+	<property access="read" name="free_count" type="t"/>
+	<property access="read" name="max_pv" type="t"/>
+	<property access="read" name="max_lv" type="t"/>
+	<property access="read" name="tags" type="as"/>
+	<property access="read" name="lvs" type="ao"/>
+	<property access="read" name="pvs" type="ao"/>
+
+	<!--
+	<property access="read" name="pv_count" type="t"/>
+	<property access="read" name="lv_count" type="t"/>
+    <property access="read" name="mda_count" type="t"/>
+    <property access="read" name="mda_used_count" type="t"/>
+    <property access="read" name="snap_count" type="t"/>
+	<property access="read" name="alloc_contiguous" type="b"/>
+    <property access="read" name="alloc_normal" type="b"/>
+    <property access="read" name="mda_size_bytes" type="t"/>
+    <property access="read" name="fmt" type="s"/>
+    <property access="read" name="readable" type="b"/>
+    <property access="read" name="sys_id" type="s"/>
+    <property access="read" name="mda_free" type="t"/>
+    <property access="read" name="alloc_anywhere" type="b"/>
+    <property access="read" name="writeable" type="b"/>
+    <property access="read" name="profile" type="s"/>
+    <property access="read" name="alloc_cling" type="b"/>
+	-->
+
+  </interface>
+</node>
diff --git a/daemons/lvmdbusd/example_client.c b/daemons/lvmdbusd/example_client.c
new file mode 100644
index 0000000..8194c66
--- /dev/null
+++ b/daemons/lvmdbusd/example_client.c
@@ -0,0 +1,218 @@
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include "lvm_dbus_generated.h"
+
+/*
+ * Simple example of how to use the object manager client side to retrieve
+ * information.
+ *
+ * Sample code take from:
+ * https://github.com/GNOME/glib/blob/master/gio/tests/gdbus-example-objectmanager-client.c
+ * Compile this sample via:
+ *
+  gcc -Wall -g -O0 -I. `pkg-config --cflags --libs gio-unix-2.0` \
+       example_client.c lvm_dbus_generated.c
+ */
+
+typedef enum {PV, VG, LV, MONITOR} op_t;
+
+static op_t arg_to_op(gchar *s) {
+	if (!strcmp(s, "pv")) {
+		return PV;
+	}
+	if (!strcmp(s, "lv")) {
+		return LV;
+	}
+	if (!strcmp(s, "vg")) {
+		return VG;
+	}
+	return MONITOR;
+}
+
+static void print_properties(GDBusInterface *intf)
+{
+	GDBusPropertyInfo **p;
+	GDBusPropertyInfo **properties = g_dbus_interface_get_info(intf)->properties;
+
+	if ( properties ) {
+		for( p = properties; *p != NULL; p+=1 ) {
+			gchar *s = NULL;
+			GVariant *v = g_dbus_proxy_get_cached_property(
+							G_DBUS_PROXY(intf), (*p)->name);
+			s = g_variant_print(v, FALSE);
+			g_print("%s:%s\n", (*p)->name, s);
+			g_free(s);
+			g_variant_unref(v);
+		}
+	}
+}
+
+static void print_objects (GDBusObjectManager *manager, op_t op)
+{
+	GList *objects = NULL;
+	GList *l = NULL;
+
+	objects = g_dbus_object_manager_get_objects (manager);
+
+	for (l = objects; l != NULL; l = l->next) {
+		lvm1Object *object = LVM1_OBJECT(l->data);
+		GList *interfaces;
+		GList *ll;
+
+		interfaces = g_dbus_object_get_interfaces(G_DBUS_OBJECT (object));
+		for (ll = interfaces; ll != NULL; ll = ll->next) {
+			/* Note that @interface is really a GDBusProxy instance */
+
+			GDBusInterface *interface = G_DBUS_INTERFACE(ll->data);
+
+			switch (op) {
+				case(PV): {
+					if (LVM1_IS_PV(interface)) {
+						print_properties(interface);
+
+						/*
+						 * Once you know what interface something is you can use the
+						 * generated functions for it too, eg.
+						 */
+						//lvm1Pv *pv = LVM1_PV(interface);
+						//g_print("PV Name= %s\n", lvm1_pv_get_name(pv));
+					}
+					break;
+				}
+				case(VG): {
+					if (LVM1_IS_VG(interface)) {
+						print_properties(interface);
+					}
+					break;
+				}
+				case(LV): {
+					if (LVM1_IS_LV(interface)) {
+						print_properties(interface);
+					}
+					break;
+				}
+				default:
+					break;
+			}
+		}
+		g_list_free_full(interfaces, g_object_unref);
+	}
+	g_list_free_full(objects, g_object_unref);
+}
+
+static void on_object_added (GDBusObjectManager *manager,
+								GDBusObject        *object,
+                 				gpointer            user_data) {
+	gchar *owner;
+	owner = g_dbus_object_manager_client_get_name_owner(
+			  G_DBUS_OBJECT_MANAGER_CLIENT (manager));
+	g_print("Added object at %s (owner %s)\n",
+			g_dbus_object_get_object_path (object), owner);
+	g_free (owner);
+}
+
+static void on_object_removed (GDBusObjectManager *manager,
+								GDBusObject        *object,
+								gpointer            user_data)
+{
+	gchar *owner;
+	owner = g_dbus_object_manager_client_get_name_owner(
+				G_DBUS_OBJECT_MANAGER_CLIENT (manager));
+	g_print("Removed object at %s (owner %s)\n",
+			g_dbus_object_get_object_path (object), owner);
+	g_free(owner);
+}
+
+static void on_notify_name_owner (GObject    *object,
+									GParamSpec *pspec,
+									gpointer    user_data)
+{
+	GDBusObjectManagerClient *manager = G_DBUS_OBJECT_MANAGER_CLIENT (object);
+	gchar *name_owner;
+
+	name_owner = g_dbus_object_manager_client_get_name_owner (manager);
+	g_print ("name-owner: %s\n", name_owner);
+	g_free (name_owner);
+}
+
+static void on_interface_proxy_properties_changed(
+							GDBusObjectManagerClient *manager,
+							GDBusObjectProxy         *object_proxy,
+							GDBusProxy               *interface_proxy,
+							GVariant                 *changed_properties,
+							const gchar *const       *invalidated_properties,
+							gpointer                  user_data)
+{
+	GVariantIter iter;
+	const gchar *key;
+	GVariant *value;
+	gchar *s;
+
+	g_print ("Properties Changed on %s:\n",
+			g_dbus_object_get_object_path (G_DBUS_OBJECT (object_proxy)));
+	g_variant_iter_init (&iter, changed_properties);
+	while (g_variant_iter_next (&iter, "{&sv}", &key, &value)) {
+	  s = g_variant_print (value, TRUE);
+	  g_print ("  %s -> %s\n", key, s);
+	  g_variant_unref (value);
+	  g_free (s);
+	}
+}
+
+
+int main(int argc, char *argv[]) {
+	GMainLoop *loop = NULL;
+	GDBusObjectManager *obj_manager = NULL;
+	GError *error = NULL;
+	op_t op;
+
+	if (argc != 2) {
+		g_print("Syntax: %s [pv|vg|lv|monitor]\n", argv[0]);
+		exit(1);
+	}
+
+	op = arg_to_op(argv[1]);
+
+	obj_manager = lvm1_object_manager_client_new_for_bus_sync(
+			G_BUS_TYPE_SESSION,
+			G_DBUS_OBJECT_MANAGER_CLIENT_FLAGS_NONE,
+			"com.redhat.lvm1",
+			"/com/redhat/lvm1",
+			NULL,
+			&error);
+
+	if (obj_manager) {
+		if ( op == MONITOR ) {
+			/* Useful to see object & property changes when they occur */
+
+			g_signal_connect(obj_manager,
+					"notify::name-owner",
+					G_CALLBACK (on_notify_name_owner),
+					NULL);
+			g_signal_connect (obj_manager,
+					"object-added",
+					G_CALLBACK (on_object_added),
+					NULL);
+			g_signal_connect (obj_manager,
+					"object-removed",
+					G_CALLBACK (on_object_removed),
+					NULL);
+			g_signal_connect (obj_manager,
+					"interface-proxy-properties-changed",
+					G_CALLBACK (on_interface_proxy_properties_changed),
+					NULL);
+			loop = g_main_loop_new(NULL, FALSE);
+			g_main_loop_run(loop);
+		} else {
+			print_objects(obj_manager, op);
+		}
+
+		g_object_unref (obj_manager);
+
+	} else {
+		printf("Error getting object manager %s\n", error->message);
+		g_error_free(error);
+	}
+	return 0;
+}
\ No newline at end of file
diff --git a/daemons/lvmdbusd/lvmdbusd.c b/daemons/lvmdbusd/lvmdbusd.c
new file mode 100644
index 0000000..9bb941b
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdbusd.c
@@ -0,0 +1,765 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the lvm
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+
+/*
+ * lvmdbusd: Experimental lvm dbus API
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <glib.h>
+#include "lvm_dbus_generated.h"
+#include "lvm2app.h"
+#include <stdint.h>
+#include <libgen.h>
+
+
+#define VERSION "1"
+#define BASE_PATH "/com/redhat/lvm" VERSION
+#define BASE_INTERFACE "com.redhat.lvm" VERSION
+#define VG_INTERFACE BASE_INTERFACE ".vg"
+#define PV_INTERFACE BASE_INTERFACE ".pv"
+
+static struct _daemon_data {
+	lvm_t libh;
+} daemon_data;
+
+static GMainLoop *main_loop = NULL;
+static GDBusObjectManagerServer *obj_manager = NULL;
+
+static char *obj_path(const char *format_string, const char *name)
+{
+	char obj_name[128];
+
+	if (name) {
+		snprintf(obj_name, sizeof(obj_name), format_string, name);
+		return g_strdup(obj_name);
+	}
+	return NULL;
+}
+
+static char *pv_object_path(pv_t pv)
+{
+	char *o_path = NULL;
+	char *bn = NULL;
+
+	if (pv && lvm_pv_get_name(pv)) {
+		// basename call mucks with parameter passed to it.
+		bn = g_strdup(lvm_pv_get_name(pv));
+		if (bn) {
+			o_path = obj_path(BASE_PATH "/pv/%s", basename(bn));
+			free(bn);
+		}
+	}
+	return o_path;
+}
+
+static char *lv_object_path(lv_t lv)
+{
+	char *o_path = NULL;
+	if (lv && lvm_lv_get_name(lv)) {
+		o_path = obj_path(BASE_PATH "/lv/%s", lvm_lv_get_name(lv));
+	}
+	return o_path;
+}
+
+
+static void build_pv(GDBusConnection *connection, struct _daemon_data *data,
+						pv_t pv, vg_t vg)
+{
+	lvm1Pv *object;
+	GDBusObjectSkeleton *interface_container = NULL;
+	char *pv_obj_path = NULL;
+	char *vg_obj_path = NULL;
+
+	printf("build pv %s\n", lvm_pv_get_name(pv));
+
+	pv_obj_path = pv_object_path(pv);
+	if (pv_obj_path) {
+		vg_obj_path = obj_path(BASE_PATH "/vg/%s", lvm_vg_get_name(vg));
+
+		interface_container = g_dbus_object_skeleton_new(pv_obj_path);
+		object = lvm1_pv_skeleton_new();
+
+		if (pv_obj_path && vg_obj_path && interface_container && object) {
+
+			lvm1_pv_set_name(object, lvm_pv_get_name(pv));
+			lvm1_pv_set_uuid(object, lvm_pv_get_uuid(pv));
+			lvm1_pv_set_vg(object, vg_obj_path);
+			lvm1_pv_set_size_bytes(object, lvm_pv_get_size(pv));
+			lvm1_pv_set_free_bytes(object, lvm_pv_get_free(pv));
+			lvm1_pv_set_dev_size_bytes(object, lvm_pv_get_dev_size(pv));
+
+			g_dbus_object_skeleton_add_interface(interface_container,
+					G_DBUS_INTERFACE_SKELETON(object));
+			// Register call backs for methods.
+
+			g_dbus_object_manager_server_export(obj_manager,
+					G_DBUS_OBJECT_SKELETON(interface_container));
+		} else {
+			if (object) {
+				g_object_unref(object);
+				object = NULL;
+			}
+		}
+	}
+
+	if (interface_container) {
+		g_object_unref(interface_container);
+		interface_container = NULL;
+	}
+
+	free(vg_obj_path);
+	free(pv_obj_path);
+}
+
+static gchar const **build_string_array_from_dm_list(struct dm_list *str_list)
+{
+	gchar const **str_array = NULL;
+	struct lvm_str_list *item = NULL;
+	int count = 0;
+
+	if (str_list) {
+		/* TODO: Switch to g_array use */
+		dm_list_iterate_items(item, str_list) {
+			count += 1;
+		}
+
+		if (count) {
+			uint pos = 0;
+			item = NULL;
+			str_array = (gchar const **)calloc((count + 1), sizeof(gchar*));
+
+			if (str_array) {
+				dm_list_iterate_items(item, str_list) {
+					str_array[pos] = item->str;
+					pos += 1;
+				}
+			}
+		}
+	}
+	return str_array;
+}
+
+
+/**
+ * Returns a GPtrArray
+ * @param vg
+ * @return
+ */
+static GPtrArray *vg_get_lvs(vg_t vg)
+{
+	GPtrArray *lvs = g_ptr_array_new_with_free_func(g_free);
+	struct dm_list *lv_list = lvm_vg_list_lvs(vg);
+
+	if (lvs && lv_list) {
+		struct lvm_lv_list *lvl;
+		dm_list_iterate_items(lvl, lv_list) {
+			g_ptr_array_add(lvs, lv_object_path(lvl->lv));
+		}
+		/* Add an empty at the end to terminate */
+		g_ptr_array_add(lvs, NULL);
+	}
+	return lvs;
+}
+
+/**
+ * Returns a GPtrArray
+ * @param vg
+ * @return
+ */
+static GPtrArray *vg_get_pvs(vg_t vg)
+{
+	GPtrArray *pvs = g_ptr_array_new_with_free_func(g_free);
+	struct dm_list *pvs_list = lvm_vg_list_pvs(vg);
+
+	if (pvs && pvs_list) {
+		struct lvm_pv_list *pvl;
+		dm_list_iterate_items(pvl, pvs_list) {
+			g_ptr_array_add(pvs, pv_object_path(pvl->pv));
+		}
+		/* Add an empty at the end to terminate */
+		g_ptr_array_add(pvs, NULL);
+	}
+	return pvs;
+}
+
+static int null_terminated_array_len(const gchar *const *b)
+{
+	int len = 0;
+	const gchar *const *p = NULL;
+
+	for( p = b; *p != NULL; ++p ) {
+		len +=1;
+	}
+	return len;
+}
+
+
+static gboolean string_arrays_same(GPtrArray *a, const gchar *const *b)
+{
+	int b_len = null_terminated_array_len(b);
+	int a_len = (a->len) ? a->len - 1 : 0;  /* A has NULL added which + count */
+
+	if (a_len == b_len) {
+		for (int outer=0; outer < a_len; ++outer) {
+			gboolean found = FALSE;
+			gchar *outer_str = g_ptr_array_index(a, outer);
+
+			for (int inner=0; inner < b_len; ++inner) {
+				if (!strcmp(outer_str, b[inner])) {
+					found = TRUE;
+					break;
+				}
+			}
+			if (!found) {
+				return FALSE;
+			}
+		}
+		return TRUE;
+	}
+	return FALSE;
+}
+
+
+/**
+ * Update the VG dbus properties if they are different than existing.
+ * @param data
+ * @param vg_name
+ * @param vg_obj
+ */
+static void vg_properties_update(struct _daemon_data *data,
+									const gchar *vg_name, lvm1Vg *vg_obj)
+{
+	vg_t vg = lvm_vg_open(data->libh, vg_name, "r", 0);
+	if (vg ) {
+		/* Is there a better way to do this? */
+
+		if (strcmp(lvm1_vg_get_name(vg_obj), lvm_vg_get_name(vg))) {
+			lvm1_vg_set_name(vg_obj, lvm_vg_get_name(vg));
+		}
+
+		if (strcmp(lvm1_vg_get_uuid(vg_obj), lvm_vg_get_uuid(vg))) {
+			lvm1_vg_set_uuid(vg_obj, lvm_vg_get_uuid(vg));
+		}
+
+		if (lvm1_vg_get_seqno(vg_obj) != lvm_vg_get_seqno(vg)) {
+			lvm1_vg_set_seqno(vg_obj, lvm_vg_get_seqno(vg));
+		}
+
+		if (lvm1_vg_get_partial(vg_obj) != lvm_vg_is_partial(vg)) {
+			lvm1_vg_set_partial(vg_obj, lvm_vg_is_partial(vg));
+		}
+
+		if (lvm1_vg_get_clustered(vg_obj) != lvm_vg_is_clustered(vg)) {
+			lvm1_vg_set_clustered(vg_obj, lvm_vg_is_clustered(vg));
+		}
+
+		if (lvm1_vg_get_exportable(vg_obj) != lvm_vg_is_exported(vg)) {
+			lvm1_vg_set_exportable(vg_obj, lvm_vg_is_exported(vg));
+		}
+
+		if (lvm1_vg_get_size_bytes(vg_obj) != lvm_vg_get_size(vg)) {
+			lvm1_vg_set_size_bytes(vg_obj, lvm_vg_get_size(vg));
+		}
+
+		if (lvm1_vg_get_extent_count(vg_obj) != lvm_vg_get_extent_count(vg)) {
+			lvm1_vg_set_extent_count(vg_obj, lvm_vg_get_extent_count(vg));
+		}
+
+		if (lvm1_vg_get_extent_size_bytes(vg_obj) != lvm_vg_get_extent_size(vg)) {
+			lvm1_vg_set_extent_size_bytes(vg_obj, lvm_vg_get_extent_size(vg));
+		}
+
+		if (lvm1_vg_get_extent_count(vg_obj) != lvm_vg_get_extent_count(vg)) {
+			lvm1_vg_set_extent_count(vg_obj, lvm_vg_get_extent_count(vg));
+		}
+
+		if (lvm1_vg_get_free_count(vg_obj) != lvm_vg_get_free_extent_count(vg)) {
+			lvm1_vg_set_free_count(vg_obj, lvm_vg_get_free_extent_count(vg));
+		}
+
+		if (lvm1_vg_get_max_pv(vg_obj) != lvm_vg_get_max_pv(vg)) {
+			lvm1_vg_set_max_pv(vg_obj, lvm_vg_get_max_pv(vg));
+		}
+
+		if (lvm1_vg_get_max_lv(vg_obj) != lvm_vg_get_max_lv(vg)) {
+			lvm1_vg_set_max_lv(vg_obj, lvm_vg_get_max_lv(vg));
+		}
+
+		/* Get the current tags, pvs and lvs and compare to dbus objects */
+		GPtrArray *lvs = vg_get_lvs(vg);
+		GPtrArray *pvs = vg_get_pvs(vg);
+		const gchar *const *dbus_lvs = lvm1_vg_get_lvs(vg_obj);
+		const gchar *const *dbus_pvs = lvm1_vg_get_pvs(vg_obj);
+
+		if ( !string_arrays_same(lvs, dbus_lvs)) {
+			lvm1_vg_set_lvs(vg_obj, (gchar const **)lvs->pdata);
+		}
+
+		if ( !string_arrays_same(pvs, dbus_pvs)) {
+			lvm1_vg_set_pvs(vg_obj, (gchar const **)pvs->pdata);
+		}
+
+		g_ptr_array_free(lvs, TRUE);
+		g_ptr_array_free(pvs, TRUE);
+
+		lvm_vg_close(vg);
+	}
+}
+
+static pv_t get_pv_from_vg(vg_t vg, const gchar *name)
+{
+	struct lvm_pv_list *pvl;
+	struct dm_list *pv_list = lvm_vg_list_pvs(vg);
+	dm_list_iterate_items(pvl, pv_list) {
+		if (!strcmp(name, lvm_pv_get_name(pvl->pv))) {
+			return pvl->pv;
+		}
+	}
+	return NULL;
+}
+
+
+static void pv_properties_update(struct _daemon_data *data,
+									const gchar *vg_name, lvm1Pv *pv_obj)
+{
+	vg_t vg = lvm_vg_open(data->libh, vg_name, "r", 0);
+	const gchar *pv_name = lvm1_pv_get_name(pv_obj);
+	if (vg ) {
+		pv_t pv = get_pv_from_vg(vg, pv_name);
+		char *vg_obj_path = obj_path(BASE_PATH "/vg/%s", vg_name);
+
+		if (pv && vg_obj_path) {
+			if (strcmp(lvm1_pv_get_uuid(pv_obj),lvm_pv_get_uuid(pv))) {
+				lvm1_pv_set_uuid(pv_obj, lvm_pv_get_uuid(pv));
+			}
+
+			if (lvm1_pv_get_size_bytes(pv_obj) != lvm_pv_get_size(pv)) {
+				lvm1_pv_set_size_bytes(pv_obj, lvm_pv_get_size(pv));
+			}
+
+			if (strcmp(lvm1_pv_get_vg(pv_obj), vg_obj_path)) {
+				lvm1_pv_set_vg(pv_obj, vg_obj_path);
+			}
+
+			if (lvm1_pv_get_free_bytes(pv_obj) != lvm_pv_get_free(pv)) {
+				lvm1_pv_set_free_bytes(pv_obj, lvm_pv_get_free(pv));
+			}
+
+			if (lvm1_pv_get_dev_size_bytes(pv_obj) != lvm_pv_get_dev_size(pv)) {
+				lvm1_pv_set_dev_size_bytes(pv_obj, lvm_pv_get_dev_size(pv));
+			}
+
+			free(vg_obj_path);
+		}
+		lvm_vg_close(vg);
+	}
+}
+
+static gboolean remove_lv(struct _daemon_data *data,
+							const gchar *vg_name, const gchar *lv_name)
+{
+	gboolean removed = FALSE;
+	vg_t vg = lvm_vg_open(data->libh, vg_name, "w", 0);
+	if ( vg ) {
+		struct lvm_lv_list *lvl;
+		struct dm_list *lv_list = lvm_vg_list_lvs(vg);
+
+		dm_list_iterate_items(lvl, lv_list) {
+			if( 0 == strcmp(lvm_lv_get_name(lvl->lv), lv_name)) {
+				int rc_remove = lvm_vg_remove_lv(lvl->lv);
+				if ( 0 == rc_remove ) {
+					removed = TRUE;
+					break;
+				} else {
+					//TODO: Generate dbus error
+				}
+			}
+		}
+		lvm_vg_close(vg);
+	}
+	return removed;
+}
+
+static gboolean on_lv_remove(lvm1Lv *object,
+								GDBusMethodInvocation *invocation,
+								gpointer user_data)
+{
+	struct _daemon_data *data = (struct _daemon_data *) user_data;
+	gchar const *vg_obj_path = NULL;
+	gchar const *vg_name = NULL;
+	gchar const *lv_name = NULL;
+	lvm1Vg *vg_obj = NULL;
+
+	vg_obj_path = lvm1_lv_get_vg(object);  /* Do not free, belongs to object */
+	vg_obj = LVM1_VG(g_dbus_object_manager_get_interface(
+						G_DBUS_OBJECT_MANAGER(obj_manager),
+						vg_obj_path, VG_INTERFACE));
+
+	if (vg_obj && vg_obj_path) {
+		vg_name = lvm1_vg_get_name(vg_obj);  /* Do not free */
+		lv_name = lvm1_lv_get_name(object);  /* Do not free */
+
+		/*
+		 * When a LV gets removed the VG that contained it
+		 * needs to be updated as well as the relevant PVs that
+		 * contained data for the LV.  At the moment we don't
+		 * have this specific information available for the
+		 * specific PVs so we will walk all of them checking to
+		 * see which ones have changed and if they have changed
+		 * we will update their properties.
+		 */
+		if (remove_lv(data, vg_name, lv_name)) {
+			const gchar *const *p = NULL;
+			const gchar *const *dbus_pvs = lvm1_vg_get_pvs(vg_obj);
+
+			/* Loop through PVs and check for updates */
+			for (p = dbus_pvs; *p != NULL; ++p) {
+				printf("Checkout PV %s for updates\n", *p);
+				lvm1Pv *pv_obj = LVM1_PV(g_dbus_object_manager_get_interface(
+						G_DBUS_OBJECT_MANAGER(obj_manager), *p, PV_INTERFACE));
+				if ( pv_obj ) {
+					pv_properties_update(data, vg_name, pv_obj);
+					g_object_unref(pv_obj);
+					pv_obj = NULL;
+				}
+			}
+
+			/* Update VG*/
+			vg_properties_update(data, vg_name, vg_obj);
+
+			if (!g_dbus_object_manager_server_unexport(obj_manager,
+                        g_dbus_method_invocation_get_object_path(invocation))) {
+				printf("Failed to unexport object from object manager\n");
+			}
+		}
+	} else {
+		// TODO: build dbus error
+		printf("Unable to retrieve interface\n");
+	}
+
+	if (vg_obj) {
+		g_object_unref(vg_obj);
+	}
+
+	/* Return true, method is supported, false means not supported AFAIKT */
+	return TRUE;
+}
+
+
+static void build_lv(GDBusConnection *connection, struct _daemon_data *data,
+						lv_t lv, vg_t vg)
+{
+	char *lv_obj_path = NULL;
+	lvm1Lv *object = NULL;
+	GDBusObjectSkeleton *interface_container = NULL;
+	char *vg_obj_path = NULL;
+
+	printf("build lv %s\n", lvm_lv_get_name(lv));
+
+	vg_obj_path = obj_path(BASE_PATH "/vg/%s", lvm_vg_get_name(vg));
+	lv_obj_path = lv_object_path(lv);
+	interface_container = g_dbus_object_skeleton_new(lv_obj_path);
+	object = lvm1_lv_skeleton_new();
+
+	if (vg_obj_path && lv_obj_path && interface_container && object ) {
+		struct dm_list *tagsl = NULL;
+
+		lvm1_lv_set_name(object, lvm_lv_get_name(lv));
+		lvm1_lv_set_uuid(object, lvm_lv_get_uuid(lv));
+		lvm1_lv_set_attr(object, lvm_lv_get_attr(lv));
+		lvm1_lv_set_vg(object, vg_obj_path);
+		lvm1_lv_set_size_bytes(object, lvm_lv_get_size(lv));
+
+		/* Get tags */
+		tagsl = lvm_lv_get_tags(lv);
+		if (tagsl) {
+			gchar const **tags = build_string_array_from_dm_list(tagsl);
+			if (tags) {
+				lvm1_lv_set_tags(object, tags);
+				free(tags);
+				tags = NULL;
+			}
+		} else {
+			goto error;
+		}
+
+		g_signal_connect(object,
+				 "handle-remove",
+				 G_CALLBACK (on_lv_remove),
+				 data); /* user_data */
+
+		g_dbus_object_skeleton_add_interface(interface_container,
+					G_DBUS_INTERFACE_SKELETON(object));
+		g_dbus_object_manager_server_export(obj_manager,
+					G_DBUS_OBJECT_SKELETON(interface_container));
+	} else {
+		goto error;
+	}
+
+out:
+	if (interface_container) {
+		g_object_unref(interface_container);
+		interface_container = NULL;
+	}
+	free(vg_obj_path);
+	free(lv_obj_path);
+
+	return;
+
+error:
+	if (object) {
+		g_object_unref(object);
+			object = NULL;
+	}
+	goto out;
+}
+
+static void build_vg(GDBusConnection *connection, struct _daemon_data *data,
+						vg_t vg, gchar const **pvs, gchar const **lvs)
+{
+	char *vg_obj_path = NULL;
+	lvm1Vg *object = NULL;
+	GDBusObjectSkeleton *interface_container = NULL;
+
+	printf("build vg %s\n", lvm_vg_get_name(vg));
+
+	vg_obj_path = obj_path(BASE_PATH "/vg/%s", lvm_vg_get_name(vg));
+	interface_container = g_dbus_object_skeleton_new(vg_obj_path);
+	object = lvm1_vg_skeleton_new();
+
+
+	printf("vg interface_container %p\n", vg_obj_path);
+	printf("vg object %p\n", object);
+
+	if (vg_obj_path && interface_container && object) {
+		struct dm_list *tagsl = NULL;
+
+		lvm1_vg_set_name(object, lvm_vg_get_name(vg));
+		lvm1_vg_set_name(object, lvm_vg_get_name(vg));
+		lvm1_vg_set_uuid(object, lvm_vg_get_uuid(vg));
+		lvm1_vg_set_seqno(object, lvm_vg_get_seqno(vg));
+		lvm1_vg_set_partial(object, lvm_vg_is_partial(vg));
+		lvm1_vg_set_clustered(object, lvm_vg_is_clustered(vg));
+		lvm1_vg_set_exportable(object, lvm_vg_is_exported(vg));
+		lvm1_vg_set_size_bytes(object, lvm_vg_get_size(vg));
+		lvm1_vg_set_extent_count(object, lvm_vg_get_extent_count(vg));
+		lvm1_vg_set_extent_size_bytes(object, lvm_vg_get_extent_size(vg));
+		lvm1_vg_set_extent_count(object, lvm_vg_get_extent_count(vg));
+		lvm1_vg_set_free_count(object, lvm_vg_get_free_extent_count(vg));
+		lvm1_vg_set_max_pv(object, lvm_vg_get_max_pv(vg));
+		lvm1_vg_set_max_lv(object, lvm_vg_get_max_lv(vg));
+
+		// Get tags
+		tagsl = lvm_vg_get_tags(vg);
+		if (tagsl) {
+			gchar const **tags = build_string_array_from_dm_list(tagsl);
+			if (tags) {
+				lvm1_vg_set_tags(object, tags);
+				free(tags);
+				tags = NULL;
+			}
+		}
+
+		if (pvs) {
+			lvm1_vg_set_pvs(object, pvs);
+		}
+
+		if (lvs) {
+			lvm1_vg_set_lvs(object, lvs);
+		}
+
+		g_dbus_object_skeleton_add_interface(interface_container,
+					G_DBUS_INTERFACE_SKELETON(object));
+		// Register call backs for methods.
+		g_dbus_object_manager_server_export(obj_manager,
+					G_DBUS_OBJECT_SKELETON(interface_container));
+	} else {
+		if (object) {
+			g_object_unref(object);
+			object = NULL;
+		}
+	}
+
+	if (interface_container) {
+		g_object_unref(interface_container);
+		interface_container = NULL;
+	}
+
+	free(vg_obj_path);
+}
+
+static void populate(GDBusConnection *connection, struct _daemon_data *data)
+{
+	struct lvm_str_list *strl;
+	GArray *pvs_array = NULL;
+	GArray *lvs_array = NULL;
+
+	struct dm_list *vg_names = lvm_list_vg_names(data->libh);
+
+	pvs_array = g_array_new(TRUE, TRUE, sizeof(gchar*));
+	lvs_array = g_array_new(TRUE, TRUE, sizeof(gchar*));
+
+	if (vg_names && pvs_array && lvs_array) {
+		dm_list_iterate_items(strl, vg_names) {
+			vg_t vg;
+
+			// Open the VG
+			vg = lvm_vg_open(data->libh, strl->str, "r", 0);
+
+			if (vg) {
+				struct dm_list *lv_list = lvm_vg_list_lvs(vg);
+				struct dm_list *pv_list = lvm_vg_list_pvs(vg);
+				if (pv_list) {
+					struct lvm_pv_list *pvl;
+					dm_list_iterate_items(pvl, pv_list) {
+						char *o_path = pv_object_path(pvl->pv);
+						build_pv(connection, data, pvl->pv, vg);
+						g_array_append_val(pvs_array, o_path);
+					}
+				}
+
+				if (lv_list) {
+					struct lvm_lv_list *lvl;
+					dm_list_iterate_items(lvl, lv_list) {
+						char *o_path = lv_object_path(lvl->lv);
+						build_lv(connection, data, lvl->lv, vg);
+						g_array_append_val(lvs_array, o_path);
+					}
+				}
+
+				// Construct the VG
+				build_vg(connection, data, vg,
+						(gchar const **)pvs_array->data,
+						(gchar const **)lvs_array->data);
+				lvm_vg_close(vg);
+			}
+		}
+	}
+
+	if (pvs_array) {
+		for( int i = 0; i < pvs_array->len; ++i ) {
+			free(g_array_index(pvs_array, gchar*, i));
+		}
+		g_array_free(pvs_array, TRUE);
+		pvs_array = NULL;
+	}
+
+	if (lvs_array) {
+		for( int i = 0; i < lvs_array->len; ++i ) {
+			free(g_array_index(lvs_array, gchar*, i));
+		}
+		g_array_free(lvs_array, TRUE);
+		lvs_array = NULL;
+	}
+}
+
+static void on_bus_acquired(GDBusConnection *connection, const gchar *name,
+	gpointer user_data)
+{
+	lvm1Manager *manager = NULL;
+	GDBusObjectSkeleton *object = NULL;
+
+	printf("bus %s acquired\n", name);
+
+	// Create an object manager
+	obj_manager = g_dbus_object_manager_server_new(BASE_PATH);
+
+	// Create the Manager object
+	object = g_dbus_object_skeleton_new( BASE_PATH "/Manager");
+
+	manager = lvm1_manager_skeleton_new();
+	g_dbus_object_skeleton_add_interface(object, G_DBUS_INTERFACE_SKELETON(manager));
+	g_dbus_object_manager_server_export(obj_manager, G_DBUS_OBJECT_SKELETON(object));
+	g_object_unref(object);
+
+	//Create the PV/VG/LV objects
+	populate(connection, (struct _daemon_data*)user_data);
+
+	g_dbus_object_manager_server_set_connection(obj_manager, connection);
+}
+
+static void on_name_acquired (GDBusConnection *connection,
+                  const gchar     *name,
+                  gpointer         user_data)
+{
+}
+
+static void on_name_lost (GDBusConnection *connection,
+              const gchar     *name,
+              gpointer         user_data)
+{
+}
+
+void free_dameon_data(void *data)
+{
+	printf("free_dameon_data...\n");
+	g_assert(data != NULL);
+	struct _daemon_data *d = (struct _daemon_data *)data;
+	lvm_quit(d->libh);
+	d->libh = NULL;
+}
+
+void signal_handler(int s)
+{
+    if( SIGTERM == s || SIGINT == s) {
+		if (main_loop) {
+			/* Need to find out if this is safe to call from within a signal
+			 * handler*/
+			g_main_loop_quit(main_loop);
+		}
+    }
+}
+
+int main(void)
+{
+	guint owner_id;
+
+	if(signal(SIGTERM, signal_handler) == SIG_ERR) {
+		printf("Can't catch signal SIGTERM\n");
+		exit(1);
+    }
+
+	if(signal(SIGINT, signal_handler) == SIG_ERR) {
+		printf("Can't catch signal SIGINT\n");
+		exit(1);
+    }
+
+	// Setup the data to use
+	daemon_data.libh = lvm_init(NULL);
+
+	g_assert(daemon_data.libh != NULL);
+
+	/* Set up DBus name, see callback */
+	owner_id = g_bus_own_name(G_BUS_TYPE_SESSION,
+				BASE_INTERFACE,
+				G_BUS_NAME_OWNER_FLAGS_NONE,
+				on_bus_acquired,
+				on_name_acquired,
+				on_name_lost,
+				&daemon_data,		// user data
+				free_dameon_data	// user date free function
+		);
+
+	main_loop = g_main_loop_new(NULL, FALSE);
+	g_main_loop_run(main_loop);
+
+	g_bus_unown_name(owner_id);
+	g_main_loop_unref(main_loop);
+
+	printf("Exiting...\n");
+	return 0;
+}
diff --git a/make.tmpl.in b/make.tmpl.in
index 731dab7..10aa5f8 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -64,6 +64,9 @@ BLKID_LIBS = @BLKID_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 TESTING = @TESTING@
 
+GIO_CFLAGS = @GIO_CFLAGS@
+GIO_LIBS = @GIO_LIBS@
+
 # Setup directory variables
 prefix = @prefix@
 exec_prefix = @exec_prefix@
-- 
1.7.1


