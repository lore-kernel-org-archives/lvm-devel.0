From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:29 +0000 (UTC)
Subject: master - lvmdbusd: Fix dbus object with only properties and no method
Message-ID: <20160919203829.6F7B160D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cb886551160cecc50a20d1867aaa5e1e75b61a6
Commit:        9cb886551160cecc50a20d1867aaa5e1e75b61a6
Parent:        cb2b2615107e84dc3aba7b3e4b6755ed01c18cb0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 19 09:54:24 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:47 2016 -0500

lvmdbusd: Fix dbus object with only properties and no method

Gris debugged that when we don't have a method the introspection
data is missing the interface itself eg.

<interface name="<your_obj_iface_name>" />

When adding the properties to the dbus object introspection we will
add the interface too if it's missing.  This now allows us the
ability to have a dbus object with only properties.
---
 daemons/lvmdbusd/lv.py    |    7 -------
 daemons/lvmdbusd/utils.py |   24 +++++++++++++++++-------
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 4ec6f23..455f371 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -354,13 +354,6 @@ class LvCommon(AutomatedProperties):
 	def Active(self):
 		return dbus.Boolean(self.state.active == "active")
 
-	@dbus.service.method(
-		dbus_interface=LV_COMMON_INTERFACE,
-		in_signature='ia{sv}',
-		out_signature='o')
-	def _Future(self, tmo, open_options):
-		raise dbus.exceptions.DBusException(LV_COMMON_INTERFACE, 'Do not use!')
-
 
 # noinspection PyPep8Naming
 class Lv(LvCommon):
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 7d217df..4fb6a6c 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -147,17 +147,27 @@ def add_properties(xml, interface, props):
 	:param props:       Output from get_properties
 	:return: updated XML string
 	"""
-	root = Et.fromstring(xml)
-
 	if props:
+		root = Et.fromstring(xml)
+		interface_element = None
 
+		# Check to see if interface is present
 		for c in root:
-			# print c.attrib['name']
 			if c.attrib['name'] == interface:
-				for p in props:
-					temp = '<property type="%s" name="%s" access="%s"/>\n' % \
-						(p['p_t'], p['p_name'], p['p_access'])
-					c.append(Et.fromstring(temp))
+				interface_element = c
+				break
+
+		# Interface is not present, lets create it so we have something to
+		# attach the properties too
+		if interface_element is None:
+			interface_element = Et.Element("interface", name=interface)
+			root.append(interface_element)
+
+		# Add the properties
+		for p in props:
+			temp = '<property type="%s" name="%s" access="%s"/>\n' % \
+				(p['p_t'], p['p_name'], p['p_access'])
+			interface_element.append(Et.fromstring(temp))
 
 		return Et.tostring(root, encoding='utf8')
 	return xml


