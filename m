From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 01:58:41 +0200
Subject: patch2/4: lvm manpages
Message-ID: <1282262321.3337.95.camel@fermat.scientia.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

2) lvm.8.non-implemented-commands.patch
Aligned the "style" how in the two sections (built-in commands and
commands)
unimplemented commands are documented. Just cosmetic of course.
I guess the current style of the commands section is better, built-in
commands list the unimplemented one just as the implemented commands.
Also removed pvdata from the list of unimplemented commands, as this
seems
to be an unimplemented built-in command.




--- lvm.8	2010-06-23 16:25:44.099108000 +0200
+++ lvm.8	2010-06-23 16:34:46.931357952 +0200
@@ -48,11 +48,11 @@
 .TP
 \fBhelp\fP \(em Display the help text.
 .TP
-\fBpvdata\fP \(em Not implemented in LVM2.
-.TP
 \fBsegtypes\fP \(em Display recognised logical volume segment types.
 .TP
 \fBversion\fP \(em Display version information.
+.TP
+The following built-in commands are not implemented in LVM2: pvdata
 .LP
 .SH COMMANDS
 The following commands implement the core LVM functionality.
@@ -141,7 +141,7 @@
 .TP
 \fBlvscan\fP \(em Scan (all disks) for logical volumes.
 .TP
-The following commands are not implemented in LVM2 but might be in the
future: lvmsadc, lvmsar, pvdata.
+The following commands are not implemented in LVM2 but might be in the
future: lvmsadc, lvmsar
 .SH OPTIONS
 The following options are available for many of the commands. 
 They are implemented generically and documented here rather 


