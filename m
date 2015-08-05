From: Vivek Goyal <vgoyal@redhat.com>
Date: Wed,  5 Aug 2015 09:48:05 -0400
Subject: [PATCH 1/1] man: Fix lvcreate man page and clarify -L option
Message-ID: <1438782485-29661-1-git-send-email-vgoyal@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Right now -L option does not say what's the difference between lower case
and upper case suffixes. They both are same. clarify that.

Right now man page says K represents kilobyte. That is 1000 bytes. But actually
code assumes it to be 1024 bytes. That is kibibytes. Clarify it.

https://en.wikipedia.org/wiki/Kibibyte

Signed-off-by: Vivek Goyal <vgoyal@redhat.com>
---
 man/lvcreate.8.in | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 5f5f74b..af83007 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -434,11 +434,13 @@ where the state of the flag is reported within \fBlv_attr\fP bits.
 .IR \fB\-L ", " \fB\-\-size " " LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Gives the size to allocate for the new logical volume.
 A size suffix of \fIB\fR for bytes, \fIS\fR for sectors as 512 bytes,
-\fIK\fR for kilobytes, \fIM\fR for megabytes,
-\fIG\fR for gigabytes, \fIT\fR for terabytes, \fIP\fR for petabytes
-or \fIE\fR for exabytes is optional.
+\fIK\fR for kibibytes (1024 bytes), \fIM\fR for mebibytes (1024 kibibytes),
+\fIG\fR for gibibytes (1024 mebibytes), \fIT\fR for tebibytes (1024 gibibytes),
+\fIP\fR for pebibytes (1024 tebibytes)
+or \fIE\fR for exbibytes (1024 pebibytes) is optional.
 .br
-Default unit is megabytes.
+Default unit is mebibytes. Lower case suffixes represent same unit as
+upper case suffixes.
 .TP
 .IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path }
 Creates a snapshot logical volume (or snapshot) for an existing, so called
-- 
2.1.0


