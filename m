From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 04 Nov 2009 12:40:30 -0000
Subject: [PATCH] udev: move notify rule
In-Reply-To: <20091104112655.GB17814@wavehammer.waldi.eu.org>
References: <20091030145125.GA21583@wavehammer.waldi.eu.org>	<4AEB0C50.7090500@redhat.com>
	<20091104112655.GB17814@wavehammer.waldi.eu.org>
Message-ID: <4AF1761D.9030305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/04/2009 12:26 PM, Bastian Blank wrote:
> On Fri, Oct 30, 2009 at 04:54:56PM +0100, Peter Rajnoha wrote:
>> On 10/30/2009 03:51 PM, Bastian Blank wrote:
>>> Move notify rule into the first rules file. The RUN commands is executed
>>> after everything is finished, so it makes no difference if it is set
>>> early or late.
>> yes, this is true with respect to all the other udev processing. But the point of having
>> it as 95-dm.rules is that there could be some other RUN+="..." line in the other rules.
> 
> And there are no constraints about the order of this executions. If you
> know more then the udev docu, fix it there.

OK, maybe I should assure myself with udev guys so we're 100% sure
(it's not so essential now, but it could be in the future - there
are more plans for udev usage with respect to LVM, so I need to be
sure about this ordering, that's true...).

But this is the behaviour I observed when I tested this. But you're
right, I'll make sure...

Peter


