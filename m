From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 25 Jun 2010 09:57:22 +0000
Subject: some patches to update the manpages of [pv|lv|vg]display regarding the displayed info
Message-ID: <fd7f89793f5aa892b4f6c611a96466a3@imap.dd24.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi.

In order to solve http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=404058
I've provided some patches for [pv|lv|vg]display.

What they'd do:
- align the wording style used by all three
- replace the numbers in vgcreate with "*" as used in lvcreate and
pvcreate
- for all, removed "logical volume", "physical volume" and "volume group"
in the description, if it's clear as it's the respective manpage (e.g. in
the lvdisplay manpage "logical volume size" -> "size")
- improved the explanation in some cases (e.g. actual/current LV of the
VG)
- Sometimes the unit seemed to be wrong (e.g. fixed kilobytes or sectors,
where actually MiB was used)... wrote "human-readable format" in that
cases.

Be warned:
- I removed all lines, which were not there when I tried the commands, but
this could just result because I do not have some options set or do not use
lvm1. So _REALLY_ double check if I did not remove something which is
actually not obsolete.


Again,.. please check whether everything is correct what I've changed.


Cheers,
Chris.


