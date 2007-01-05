From: Patrick Caulfield <pcaulfie@redhat.com>
Date: Fri, 05 Jan 2007 15:29:28 +0000
Subject: [PATCH] LVM2 RFC: fix return code when exclusive activation fails
In-Reply-To: <20070105135336.GY21980@agk.surrey.redhat.com>
References: <459E30C6.6090102@redhat.com>
	<20070105135336.GY21980@agk.surrey.redhat.com>
Message-ID: <459E6ED8.5060204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> I don't see that a new error code gains us anything there:
> 
> If operating on multiple objects and you need to know which ones did or
> didn't succeed, then you simply perform the operations separately.
> 
> Only use commands that operate on multiple objects when you aren't
> interested in knowing.
> 
> 
> The bugzilla referenced is discussing "What precisely should -ae" mean?
> Should it be different from "-ael" ?  Under precisely what sets of
> circumstances should it return an error, and based on the final state
> or whether a change happened?
> 
> 
> The man page says:
>     If clustered locking is enabled, -ae will  activate  exclusively
>     on  one  node and -aly will activate only on the local node.
> 
> Note that it does *not* say -ae will activate exclusively on the
> *local* node.


I did say to Kevin that this was "controversial"!

patrick


