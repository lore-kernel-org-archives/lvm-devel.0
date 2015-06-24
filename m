From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 11:28:53 +0000 (UTC)
Subject: master - commands: --withspaces also for config and lvmconfig cmd aliases
Message-ID: <20150624112853.3CFE761056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf189a572ae6fa6f7e00047925ebc965e57c6a8b
Commit:        cf189a572ae6fa6f7e00047925ebc965e57c6a8b
Parent:        7559d871fb9b8001a22493f2d18bcc2a9205656d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 24 13:28:40 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 13:28:40 2015 +0200

commands: --withspaces also for config and lvmconfig cmd aliases

---
 tools/commands.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 9403951..d89b214 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -49,13 +49,14 @@ xx(config,
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
+   "\t[--withspaces]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   unconfigured_ARG, withversions_ARG)
+   withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(devtypes,
    "Display recognised built-in block device types",
@@ -509,13 +510,14 @@ xx(lvmconfig,
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
+   "\t[--withspaces]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   unconfigured_ARG, withversions_ARG)
+   withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",


