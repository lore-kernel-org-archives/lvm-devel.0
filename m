From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:21 +0000 (UTC)
Subject: dev-mornfall-lvmcache - man: ea_start/ea_size -> ba_start/ba_size
Message-ID: <20130605120421.10F3B60F7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e7cdd60f0043d54651a8441803daaea345897f1
Commit:        5e7cdd60f0043d54651a8441803daaea345897f1
Parent:        798ed9ea1c72b24a02d38106ecaea9379a673c6f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 30 11:45:44 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 30 11:45:44 2013 +0200

man: ea_start/ea_size -> ba_start/ba_size

---
 man/pvcreate.8.in |    2 +-
 man/pvs.8.in      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index c3a652c..bd979aa 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -174,7 +174,7 @@ The start of the bootloader area is always aligned, see also \fB--dataalignment\
 and \fB--dataalignmentoffset\fP. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
 size that is requested. To see the bootloader area start and size of
-an existing Physical Volume use \fBpvs -o +ea_start,ea_size\fP.
+an existing Physical Volume use \fBpvs -o +ba_start,ba_size\fP.
 .TP
 .B \-\-setphysicalvolumesize \fIsize
 Overrides the automatically-detected size of the PV.  Use with care.
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 7fff4fd..7ec724a 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -63,7 +63,7 @@ and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
 Use \fB-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
-pv_mda_size, ea_start, ea_size, pe_start, pv_size, pv_free, pv_used,
+pv_mda_size, ba_start, ba_size, pe_start, pv_size, pv_free, pv_used,
 pv_attr, pv_pe_count, pv_pe_alloc_count, pv_tags, pv_mda_count,
 pv_mda_used_count, pvseg_start, and pvseg_size
 .IP


