From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 22 Feb 2011 16:25:00 +0100
Subject: pvcreate problem with 2 metadata areas.
In-Reply-To: <AANLkTikj8hnsTYne61TXzFyubmLLNvo1QD4kgBudxubt@mail.gmail.com>
References: <AANLkTikj8hnsTYne61TXzFyubmLLNvo1QD4kgBudxubt@mail.gmail.com>
Message-ID: <4D63D54C.5020605@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/22/2011 03:57 PM +0100, John Drescher wrote:
> localhost ~ # pvcreate /dev/md0 --pvmetadatacopies 2
>   Physical volume "/dev/md0" successfully created
> localhost ~ # pvck -v /dev/md0
>     Scanning /dev/md0
>   Found label on /dev/md0, sector 1, type=LVM2 001
>   Found text metadata area: offset=4096, size=1044480
>   Found text metadata area: offset=3215852032, size=1048576
>   /dev/md0: lseek 3216900096 failed: Invalid argument
>   Read from /dev/md0 failed
> 
> It looks like the second metadata copy is 4096 bytes too large.
> 

The last patches sent upstream yesterday are quite risky and we
are still testing these changes. However, the best way we found
was to put these changes upstream directly for even more thorough
testing.

We're still working on this and we expect some time (hopefully
short) to catch and fix all remaining bugs.

Thank you very much for the feedback. You're welcome to report
any other issues you hit. This will help us a lot to resolve all
remaining problems.

Peter


