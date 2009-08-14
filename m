From: Petr Rockai <prockai@redhat.com>
Date: Fri, 14 Aug 2009 13:49:13 +0200
Subject: [PATCH] Re: [linux-lvm] Clarifications wanted about locking process
In-Reply-To: <20090814082407.GY7033@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Fri, 14 Aug 2009 09:24:07 +0100")
References: <7fcd249b0908131713x6aeddd5bm8975df94d3c3a39a@mail.gmail.com>
	<20090814082407.GY7033@agk-dp.fab.redhat.com>
Message-ID: <87my62sjie.fsf_-_@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:
> On Thu, Aug 13, 2009 at 08:13:39PM -0400, Eric B?langer wrote:
>> Since I updated from lvm2 2.02.48 to 2.02.51, I'm getting this message
>> on boot-up:
>> Write locks are prohibited with --ignorelockingfailure.
>> Unable to obtain global lock.
>  
> Sounds like a bug.
The attached patch should fix the issue. I believe that taking a global write
lock while scanning is a mistake (I consulted with Milan, he says it only
serves to enable metadata caching).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: scanning-read-locks.diff
Type: text/x-diff
Size: 1011 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090814/b724eaea/attachment.bin>
