From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Thu, 02 May 2013 13:05:21 +0200
Subject: vg activate/deactivate
In-Reply-To: <51817D5A.2000906@redhat.com>
References: <51817D5A.2000906@redhat.com>
Message-ID: <51824871.4000805@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 1.5.2013 22:38, Tony Asleson napsal(a):
> I was looking at implementing vg activate/deactivate in lvm2app and I
> see that the function vgchange_activate will fork a polling process for
> monitoring.  Doing forks in a library is discouraged so I'm soliciting
> suggestions for making this work without forking a process.
>

Polling is only needed in some cases - i.e. when merging snapshot,
or doing pvmove operations.

However adding support for activation into lvm2app has more troubles elsewhere 
- the memory management issue -

if the tool is operating with i.e. root volume and suspend is involved in the 
activation change - we have to be sure the whole app is running in memory 
since after suspend - the memory paged on such device would freeze the 
application - this constraint is managed within lvm2 application - but so far 
it's not very clear how to 'export' this constraint outside.

Clearly installation process doesn't need any memory locking, since it's 
typically running from another boot device - so in this case we should allow
to change activation state without probably any locking since we cannot be 
freezed by suspend - but any other use case requires some thinking.

IMHO the best here would be some 'small' daemon - which would be under full 
control of lvm2app and would be doing these tasks - I cannot imaging how we 
would memory constrain i.e. python apps consuming over >100MB.
Then you would have already solution for polling as well.

So while forking in the library is discouraged - I guess this is the case 
which has justification for it.

Zdenek




