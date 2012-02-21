From: Petr Rockai <prockai@redhat.com>
Date: Wed, 22 Feb 2012 00:53:28 +0100
Subject: [PATCH] lvmetad client side
Message-ID: <87k43fyc93.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch is a semi-final version of the lvmetad
integration. In lvmetad mode it gets through all the tests fine, without
lvmetad I get a new failure in lvcreate-repair, somehow related to
vgremove -ff. I'll investigate that tomorrow. There are some other
issues that need to be sorted out, but I'll do these bits when this main
blob is merged. At least a cursory review is still needed.

Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmetad-7.7.diff
Type: text/x-patch
Size: 74203 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120222/8da1c516/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
