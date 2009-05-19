From: Milan Broz <mbroz@redhat.com>
Date: Tue, 19 May 2009 10:01:07 +0200
Subject: [PATCH] Re: [lvm-devel] lvconvert error when converting a linear
	to a	mirror
In-Reply-To: <87k54dbnwr.fsf_-_@mornfall.net>
References: <1242327416.3943.82.camel@f10-node1>	<4A113CE0.3080308@ce.jp.nec.com>
	<87k54dbnwr.fsf_-_@mornfall.net>
Message-ID: <4A126743.6050008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> Hi,
> 
> "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> writes:
>> And a comment for this comment in the code:
>>
>>>          * FIXME This check used to precede mirror->mirror conversion
>>> 	 * but didn't affect mirror->linear or linear->mirror. I do
>>> 	 * not understand what is its intention, in fact.
>> if the check wasn't done for mirror-to-linear conversion, that's a bug.
>> It seems the bug has been there since the initial version of lvconvert.c. :)
> 
> I am the author of that FIXME comment there. It seems, that Dave's proposal of
> adding a lv->status & MIRRORED check is the right solution here. Thanks both
> for noticing and explaining the issue, at the time I was implementing lvconvert
> --repair, it was not clear to me.

Ack,

(I think we already discussed several times why this check is here, 
so simple disabling multisegment mirrors is ok here.

Maybe error message could explain it to user more precisely too?)


Milan


