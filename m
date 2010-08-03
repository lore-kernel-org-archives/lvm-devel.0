From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 03 Aug 2010 09:05:12 +0200
Subject: [PATCH] Add check for semaphore kernel support
In-Reply-To: <20100802194217.GC18149@agk-dp.fab.redhat.com>
References: <4C571B89.2030309@redhat.com>
	<20100802194217.GC18149@agk-dp.fab.redhat.com>
Message-ID: <4C57BFA8.8050700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/02/2010 09:42 PM +0100, Alasdair G Kergon wrote:
>> +static int _check_semaphore_is_supported()
> 
>> +	arg.array = (unsigned short int *) (void *) &seminfo;
> 
> Double cast?
> The way I read the man page that could be arg.__buf = &seminfo.

True :) OK, I'll use that...

Peter


