From: Petr Rockai <prockai@redhat.com>
Date: Tue, 31 May 2011 13:13:25 +0200
Subject: [PATCH] deferred PV labelling, take 2 (BZ 623808)
In-Reply-To: <8762or3z4l.fsf@aldalome.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 31 May 2011 13:09:30 +0200")
References: <8762or3z4l.fsf@aldalome.int.mornfall.net.>
Message-ID: <87zkm32kdm.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
> this patch takes what I posted in
> http://www.redhat.com/archives/lvm-devel/2011-April/msg00056.html and
> makes the label_sector valid at all times (whenever the format in
> question supports labelling, anyway), as discussed.
>
> I think this was the only significant change request regarding this
> patch. Please review soon (I concede that the patch has been more or
> less ready on my disk for a couple weeks now, I just forgot to send it
> in the linuxtag/lvmetad/... rush).

Oh, the actual patches, too ... (split into 4 chunks, hopefully for
better transparency)

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmlib-pvcreate_1.diff
Type: text/x-diff
Size: 12523 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110531/dc5b0c7c/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmlib-pvcreate_2.diff
Type: text/x-diff
Size: 7104 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110531/dc5b0c7c/attachment-0001.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmlib-pvcreate_3.diff
Type: text/x-diff
Size: 5982 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110531/dc5b0c7c/attachment-0002.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmlib-pvcreate_4.diff
Type: text/x-diff
Size: 4819 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110531/dc5b0c7c/attachment-0003.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
