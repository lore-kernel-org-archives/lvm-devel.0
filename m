From: Daniel Mierswa <impulze@impulze.org>
Date: Mon, 13 Jul 2009 00:56:30 +0200
Subject: [RFC][PATCH] S.I. and consistent units
Message-ID: <4A5A6A1E.1020006@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A proposed git format-patch for unit consistency in current LVM2.
agk already answered on linux-lvm but I just now saw that you're
supposed to post patches on lvm-devel so I do it here.

>From my last mail to linux-lvm:

The functional changes are as follows:
- Users and programs currently checking the output of LVM have to
distinguish between either IEC or SI units. Currently LVM prints K, KB
and Kilobyte for SI and IEC units depending on what they passed in
--units. With the patch applied LVM prints K, KB and Kilobyte for SI
units and k, KiB and Kibibyte for IEC units.
- Users and programs currently passing LVM the uppercase size suffixes
are now telling LVM to treat that value as SI unit whereas now LVM
treats lower and uppercase suffixes as IEC (binary based unit).

-- 
Mierswa, Daniel

If you still don't like it, that's ok: that's why I'm boss. I simply
know better than you do.
               --- Linus Torvalds, comp.os.linux.advocacy, 1996/07/22
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-units.patch.gz
Type: application/gzip
Size: 17407 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090713/74b95679/attachment.gz>
