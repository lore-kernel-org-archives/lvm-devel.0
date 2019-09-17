From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 17 Sep 2019 16:08:28 -0400
Subject: dm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <CAMeeMh_cq=F3JRZQrLbXA8=DkrvWD7qWNrNyBZdLarWWKcZXAQ@mail.gmail.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
	<20190916180107.GA725@infradead.org>
	<127b8c4e-a6dc-6d5e-caff-fe1a0ca3a5bb@gmail.com>
	<CAMeeMh9t4LBwJn_CPQgFNa_Tyj22fJYHK-4qAnyn0RXm9RzCnw@mail.gmail.com>
	<20190917140632.GA3728@redhat.com>
	<alpine.LRH.2.02.1909171133100.1876@file01.intranet.prod.int.rdu2.redhat.com>
	<CAMeeMh_cq=F3JRZQrLbXA8=DkrvWD7qWNrNyBZdLarWWKcZXAQ@mail.gmail.com>
Message-ID: <20190917200827.GA5042@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 17 2019 at 11:44am -0400,
John Dorminy <jdorminy@redhat.com> wrote:

>    Makes sense, sorry I missed that detail.
> 
>    Might it be better to just extend 'dmsetup targets' to take an optional
>    target-name parameter? When I saw this change, I thought 'dmsetup targets
>    <name>' surely worked already for the purpose, and was somewhat surprised
>    when experiment disagreed. Then list_versions() has much the same code
>    change as in this change, there's a little change in validate_params(),
>    and it seems less surprising (to me) to extend the existing
>    target-information-printing dmsetup command than to add another one.

No, I don't think it better to extend 'dmsetup targets'.  There is
little to be gained in doing so.

The DM_GET_TARGET_VERSION ioctl's implementation happens to be shared
with the DM_LIST_VERSIONS ioctl (used by 'dmsetup targets') but that
doesn't imply DM_LIST_VERSIONS should be extended instead.

This is a simple change that enables userspace to accomplish a specific
goal without altering an established DM ioctl.


