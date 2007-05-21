From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 May 2007 16:23:49 -0400
Subject: [PATCH] vgcfgrestore man page fix
In-Reply-To: <20070511012843.GA7222@hp.com>
References: <20070511012843.GA7222@hp.com>
Message-ID: <1179779029.3452.10.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2007-05-11 at 11:28 +1000, James Cameron wrote:
> Trivial fix, the man page suggests the volume group name is optional and
> may be repeated, but the program will only accept one name.  This patch
> corrects the man page.
> 
> --- LVM2.2.02.21/man/vgcfgrestore.8.orig	2007-05-11 11:07:54.000000000 +1000
> +++ LVM2.2.02.21/man/vgcfgrestore.8	2007-05-11 11:10:18.000000000 +1000
> @@ -11,11 +11,11 @@
>  .RB [ \-n | \-\-name " VolumeGroupName" ]
>  .RB [ \-t | \-\-test ]
>  .RB [ \-v | \-\-verbose ]
> -.RI [ VolumeGroupName ...]
> +.RI VolumeGroupName
>  .SH DESCRIPTION
>  .B vgcfgrestore
>  allows you to restore the metadata 
> -of your volume groups from a text backup file produced by \fBvgcfgbackup\fP.
> +of a volume group from a text backup file produced by \fBvgcfgbackup\fP.
>  .SH OPTIONS
>  See \fBlvm\fP for common options.
>  .SH REPLACING PHYSICAL VOLUMES
> 
> Reference: HP 3218735444-322
> 

Thanks.  

I think we can also remove extra "--list" and "-n | --name" options
(older ones from LVM1, and even though we can specify -M1, cmdline for
LVM1 is very different).

Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-05-21 16:10:25.000000000 -0400
+++ LVM2/WHATS_NEW	2007-05-21 16:12:08.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix vgcfgrestore man pg to show mandatory VG name and remove LVM1 options.
   Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
   Remove symlinks if parent volume is deactivated.
Index: LVM2/man/vgcfgrestore.8
===================================================================
--- LVM2.orig/man/vgcfgrestore.8	2002-12-03 08:25:09.000000000 -0500
+++ LVM2/man/vgcfgrestore.8	2007-05-21 16:13:48.000000000 -0400
@@ -5,17 +5,16 @@ vgcfgrestore \- restore volume group des
 .B vgcfgrestore
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file " filename" ]
-.RB [ \-l[l] | \-\-list [--list] ]
+.RB [ \-l[l] | \-\-list ]
 .RB [ \-h | \-\-help ]
 .RB [ \-M | \-\-Metadatatype 1|2]
-.RB [ \-n | \-\-name " VolumeGroupName" ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
+.RI VolumeGroupName
 .SH DESCRIPTION
 .B vgcfgrestore
 allows you to restore the metadata 
-of your volume groups from a text backup file produced by \fBvgcfgbackup\fP.
+of a volume group from a text backup file produced by \fBvgcfgbackup\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH REPLACING PHYSICAL VOLUMES



