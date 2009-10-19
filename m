From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 19 Oct 2009 13:47:14 +0200
Subject: [PATCH 4/4] Add man page entry for dmsetup udevflags
Message-ID: <4ADC51C2.1010100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 934372e..25cb857 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -64,6 +64,9 @@ dmsetup \- low level logical volume management
 .B dmsetup mknodes
 .I [device_name]
 .br
+.B dmsetup udevflags
+.I cookie
+.br
 .B dmsetup udevcomplete
 .I cookie
 .br
@@ -303,6 +306,18 @@ is displayed.
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.
+.br
+.IP \fBudevflags
+.I cookie
+.br
+Parses given cookie value and extracts any udev control flags encoded.
+The output is in environment key format that is suitable for use in udev
+rules. If the flag has its symbolic name assigned then the ouput is
+DM_UDEV_FLAG_<flag_name>='1', DM_UDEV_FLAG_<flag_position>='1' otherwise.
+Subsystem udev flags don't have symbolic names assigned and these ones are
+always reported as DM_SUBSYSTEM_UDEV_FLAG_<flag_position>='1'. There are
+16 udev flags altogether.
+.br
 .IP \fBudevcomplete
 .I cookie
 .br


