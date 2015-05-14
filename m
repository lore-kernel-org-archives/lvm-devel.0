From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 08:53:47 +0000 (UTC)
Subject: master - conf: system_id_source is referencing CONFDIR
Message-ID: <20150514085348.05655601FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7d80806b68a97cde6dfdf64ef7bc31e9c42a6b8
Commit:        b7d80806b68a97cde6dfdf64ef7bc31e9c42a6b8
Parent:        6fb2552ef47200af1e9b1a987cb3edfdc8f3ee66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 10:50:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 10:52:55 2015 +0200

conf: system_id_source is referencing CONFDIR

Since we allow to configure /etc in configure and compile-in
dir for /etc we need to properly advertise this location later.
---
 conf/example.conf.in         |    2 +-
 lib/config/config_settings.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index fc27a98..cc02e98 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -925,7 +925,7 @@ global {
 	# 'local' section of an lvm configuration file, e.g. lvmlocal.conf.
 	# uname - Set the system ID from the hostname (uname) of the system.
 	# System IDs beginning localhost are not permitted.
-	# machineid - Use the contents of the file /etc/machine-id to set the
+	# machineid - Use the contents of the file @CONFDIR@/machine-id to set the
 	# system ID.  Some systems create this file at installation time.
 	# See 'man machine-id'.
 	# file - Use the contents of another file (system_id_file) to set
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4fd886d..d1d35b1 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -903,7 +903,7 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"'local' section of an lvm configuration file, e.g. lvmlocal.conf.\n"
 	"uname - Set the system ID from the hostname (uname) of the system.\n"
 	"System IDs beginning localhost are not permitted.\n"
-	"machineid - Use the contents of the file /etc/machine-id to set the\n"
+	"machineid - Use the contents of the file " DEFAULT_ETC_DIR "/machine-id to set the\n"
 	"system ID.  Some systems create this file at installation time.\n"
 	"See 'man machine-id'.\n"
 	"file - Use the contents of another file (system_id_file) to set\n"


