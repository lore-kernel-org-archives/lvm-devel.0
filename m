From: Petr Rockai <prockai@redhat.com>
Date: Tue, 19 May 2009 08:35:32 +0200
Subject: [PATCH] Re: [lvm-devel] lvconvert error when converting a linear to a
	mirror
In-Reply-To: <4A113CE0.3080308@ce.jp.nec.com> (Jun'ichi Nomura's message of
	"Mon, 18 May 2009 19:48:00 +0900")
References: <1242327416.3943.82.camel@f10-node1>
	<4A113CE0.3080308@ce.jp.nec.com>
Message-ID: <87k54dbnwr.fsf_-_@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

"Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> writes:
> And a comment for this comment in the code:
>
>>          * FIXME This check used to precede mirror->mirror conversion
>> 	 * but didn't affect mirror->linear or linear->mirror. I do
>> 	 * not understand what is its intention, in fact.
>
> if the check wasn't done for mirror-to-linear conversion, that's a bug.
> It seems the bug has been there since the initial version of lvconvert.c. :)

I am the author of that FIXME comment there. It seems, that Dave's proposal of
adding a lv->status & MIRRORED check is the right solution here. Thanks both
for noticing and explaining the issue, at the time I was implementing lvconvert
--repair, it was not clear to me.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-multiseg-mirror-check.diff
Type: text/x-diff
Size: 797 bytes
Desc: lvconvert-multiseg-mirror-check.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090519/a028f767/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
