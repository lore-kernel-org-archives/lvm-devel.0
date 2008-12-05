From: Stas Sergeev <stsp@aknet.ru>
Date: Fri, 05 Dec 2008 14:44:36 +0300
Subject: broken vg after vgconvert -M1
Message-ID: <49391424.8090505@aknet.ru>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello.

I tried to convert my VG to LVM1 format.
I use lvm2-2.02.33, and vgconvert segfaults.
Not knowing that the problem is alreay
fixed in CVS, I made the attached patch.
The conversion then succeeded, according
to the vgconvert message, but now I get
---
  Invalid LV in extent map (PV /dev/sdb3, PE 0, LV 0, LE 0)
  Couldn't fill logical volume maps.
  Volume group "fedora_vg" not found
---
from any lvm tool.
Oddly enough, vgck says the same.
I am a bit confused about that. Are there
any ways to recover the vg now? And what
could lead to the corruption? Could my patch
be guilty, or are there other bugs in vgconvert?

I also wonder how the lvnum_from_lvid()
supposed to ever work at all. It iterates
32 times in a loop, multiplying the int32
variable by 64 every iter. But only 5
iterations are safe, the rest may (and does)
overflow.

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvnum.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081205/229b3406/attachment.ksh>
