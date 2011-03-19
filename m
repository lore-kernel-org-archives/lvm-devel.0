From: Petr Rockai <prockai@redhat.com>
Date: Sat, 19 Mar 2011 23:41:13 +0100
Subject: [PATCH] make vg_mark_partial_lvs more robust and export it
In-Reply-To: <4D5BE238.9070806@redhat.com> (Zdenek Kabelac's message of "Wed, 
	16 Feb 2011 15:42:00 +0100")
References: <877hd0v0ht.fsf@twilight.int.mornfall.net.>
	<36088.72482223$1297846647@news.gmane.org>
	<4D5BE238.9070806@redhat.com>
Message-ID: <87tyeyohrq.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Re,

I am attaching an updated patch (since the CVS went conflicting with the
last version). It still does a scan of the LVs for the clear, but you
obviously can't do any better without a major rework of the status flag
system (where the flags would be sets of LVs instead of bits in the
LVs). So we don't.

The patch applies to current CVS and passes tests. Please review (it is
very simple and prerequisite for other patches)...

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vg-mark-partial.diff
Type: text/x-diff
Size: 3475 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110319/209cc751/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
