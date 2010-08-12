From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Aug 2010 13:07:09 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in
Message-ID: <20100812130709.18389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-12 13:07:08

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 

Log message:
	Reinstate detection of inappropriate uevent with DISK_RO set and suppress it.
	
	We still need to detect this one! We're not so strict with CHANGE events as
	with the ADD events while applying filters in the rules so this one would
	pass and it would process the rules prematurely (because it appears *before*
	the actual CHANGE event used when resuming a DM device while setting read-only
	state at the same time).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.405&r2=1.406
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW_DM	2010/08/11 13:12:31	1.405
+++ LVM2/WHATS_NEW_DM	2010/08/12 13:07:08	1.406
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Reinstate detection of inappropriate uevent with DISK_RO set and suppress it.
   Fix segfault in regex matcher with characters of ordinal value > 127.
   Use built-in rule for device aliases: block/ < dm- < disk/ < mapper/ < other.
   Wait for node creation before displaying debug info in dmsetup.
--- LVM2/udev/10-dm.rules.in	2010/07/07 11:22:46	1.10
+++ LVM2/udev/10-dm.rules.in	2010/08/12 13:07:08	1.11
@@ -42,6 +42,9 @@
 # is not recommended.
 ACTION!="add|change", GOTO="dm_end"
 
+# Rule out easy-to-detect inappropriate events first.
+ENV{DISK_RO}=="1", GOTO="dm_disable"
+
 # There is no cookie set nor any flags encoded in events not originating
 # in libdevmapper so we need to detect this and try to behave correctly.
 # For such spurious events, regenerate all flags from current udev database content


