From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 7 Jul 2009 19:28:59 -0000
Subject: LVM2 lib/display/display.c man/lvreduce.8.in m ...
Message-ID: <20090707192859.30594.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-07 19:28:58

Modified files:
	lib/display    : display.c 
	man            : lvreduce.8.in lvs.8.in pvs.8.in vgs.8.in 
	test           : t-covercmd.sh 

Log message:
	Continue to make --units and --size consistent (in code and man pages):
	
	Update units_to_bytes() to support (S)ectors: 500 bytes.
	- 500 byte (S)ectors is of questionable value but it adds to consistency
	if a user happens to use --units S.  This seems better than an error.
	
	Updated test/t-covercmd.sh to test --units [hS]
	
	Document the units that can be displayed via --units uniformly.
	- (p)etabytes and (e)xabytes were missing in pvs, vgs and lvs man pages.
	
	Made lvreduce man page "... in units of megabytes." consistent (with the
	lvextend and lvresize man pages).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/display/display.c	2009/05/13 21:27:43	1.97
+++ LVM2/lib/display/display.c	2009/07/07 19:28:57	1.98
@@ -62,14 +62,14 @@
 		v = UINT64_C(1);
 		*unit_type = *units;
 		break;
-	case 's':
-		v *= SECTOR_SIZE;
-		break;
 	case 'b':
 	case 'B':
 		v *= UINT64_C(1);
 		break;
 #define KILO UINT64_C(1024)
+	case 's':
+		v *= (KILO/2);
+		break;
 	case 'k':
 		v *= KILO;
 		break;
@@ -90,6 +90,9 @@
 		break;
 #undef KILO
 #define KILO UINT64_C(1000)
+	case 'S':
+		v *= (KILO/2);
+		break;
 	case 'K':
 		v *= KILO;
 		break;
--- LVM2/man/lvreduce.8.in	2009/07/06 19:13:26	1.3
+++ LVM2/man/lvreduce.8.in	2009/07/07 19:28:57	1.4
@@ -47,7 +47,7 @@
 free space in the Volume Group with the suffix %FREE.
 .TP
 .I \-L, \-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
-Reduce or set the logical volume size in units of megabyte by default.
+Reduce or set the logical volume size in units of megabytes.
 A size suffix of k for kilobyte, m for megabyte, 
 g for gigabytes, t for terabytes, p for petabytes 
 or e for exabytes is optional.
--- LVM2/man/lvs.8.in	2009/06/30 18:39:32	1.9
+++ LVM2/man/lvs.8.in	2009/07/07 19:28:57	1.10
@@ -9,7 +9,7 @@
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
-[\-\-units hsbkmgtHKMGT]
+[\-\-units hHbBsSkKmMgGtTpPeE]
 [\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
@@ -91,11 +91,11 @@
 .I \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hsbkmgtHKMGT
-All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
-of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
-\-\-units 3M
+.I \-\-units hHbBsSkKmMgGtTpPeE
+All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
+custom units e.g. \-\-units 3M
 .TP
 .I \-\-unquoted
 When used with --nameprefixes, output values in the field=value pairs are not quoted.
--- LVM2/man/pvs.8.in	2009/06/30 18:39:32	1.10
+++ LVM2/man/pvs.8.in	2009/07/07 19:28:57	1.11
@@ -9,7 +9,7 @@
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
-[\-\-units hsbkmgtHKMGT]
+[\-\-units hHbBsSkKmMgGtTpPeE]
 [\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [PhysicalVolume [PhysicalVolume...]]
@@ -69,11 +69,11 @@
 .I \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hsbkmgtHKMGT
-All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
-of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
-\-\-units 3M
+.I \-\-units hHbBsSkKmMgGtTpPeE
+All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
+custom units e.g. \-\-units 3M
 .TP
 .I \-\-unquoted
 When used with --nameprefixes, output values in the field=value pairs are not quoted.
--- LVM2/man/vgs.8.in	2009/06/15 17:09:32	1.8
+++ LVM2/man/vgs.8.in	2009/07/07 19:28:57	1.9
@@ -9,7 +9,7 @@
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
-[\-\-units hsbkmgtHKMGT]
+[\-\-units hHbBsSkKmMgGtTpPeE]
 [\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
@@ -80,11 +80,11 @@
 .I \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hsbkmgtHKMGT
-All sizes are output in these units: (h)uman-readable, (s)ectors, (b)ytes,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
-of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
-\-\-units 3M
+.I \-\-units hHbBsSkKmMgGtTpPeE
+All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
+custom units e.g. \-\-units 3M
 .TP
 .I \-\-unquoted
 When used with --nameprefixes, output values in the field=value pairs are not quoted.
--- LVM2/test/t-covercmd.sh	2009/03/24 13:16:35	1.6
+++ LVM2/test/t-covercmd.sh	2009/07/07 19:28:57	1.7
@@ -41,7 +41,7 @@
 lvmdiskscan
 vgdisplay --units k
 lvdisplay --units g
-for i in b k m g t p e H B K M G T P E ; do
+for i in h b s k m g t p e H B S K M G T P E ; do
     pvdisplay --units "$i" "$dev1"
 done
 


