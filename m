From: Petr Rockai <prockai@redhat.com>
Date: Tue, 31 May 2011 13:09:30 +0200
Subject: [PATCH] deferred PV labelling, take 2 (BZ 623808)
Message-ID: <8762or3z4l.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch takes what I posted in
http://www.redhat.com/archives/lvm-devel/2011-April/msg00056.html and
makes the label_sector valid at all times (whenever the format in
question supports labelling, anyway), as discussed.

I think this was the only significant change request regarding this
patch. Please review soon (I concede that the patch has been more or
less ready on my disk for a couple weeks now, I just forgot to send it
in the linuxtag/lvmetad/... rush).

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


