From: Petr Rockai <prockai@redhat.com>
Date: Mon, 04 Oct 2010 18:20:45 +0200
Subject: [PATCH] Test for vgchange -an v. max_lv interaction (BZ 509182)
Message-ID: <87fwwm3p5u.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am attaching a script that should reproduce BZ 509182 -- however, I
have been unable to get the error with current CVS, so I believe the bug
has been actually fixed, or the report is missing an important piece of
information (I have tried iterating it a whole lot of times, and I also
made sure that dmeventd monitoring actually works; there's an useful
trick you can use when debugging your shell tests:

echo thread apply all bt > bt
gdb -batch -x bt . $LOCAL_DMEVENTD

). Btw. I adjusted the script to account for the different counting of
LVs for the max_lv limit in current versions.

(Intended to live as test/t-vgchange-maxlv.sh.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: t-vgchange-maxlv.sh
Type: text/x-sh
Size: 933 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101004/d6ac324b/attachment.bin>
