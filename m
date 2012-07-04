From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 04 Jul 2012 12:01:03 +0200
Subject: master - TEST (lvcreate-raid): Allow more time for RAID arrays to sync
In-Reply-To: <20120703155232.B2168176E@lists.fedorahosted.org>
References: <20120703155232.B2168176E@lists.fedorahosted.org>
Message-ID: <4FF4145F.4040704@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 3.7.2012 17:52, Jonathan Brassow napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=149ab6921e9029e12899c280f290656b1b60742f
> Commit:        149ab6921e9029e12899c280f290656b1b60742f
> Parent:        1d0a2b919fe173e3a25e5f19d535588bb5b214e2
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Mon Jun 25 22:20:24 2012 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Mon Jun 25 22:20:24 2012 -0500
>
> TEST (lvcreate-raid): Allow more time for RAID arrays to sync
>
> My machines can run very slow sometimes causing this test to fail
> when it would otherwise have succeeded given more time.
> ---
>   test/shell/lvcreate-raid.sh |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
> index 21ab9a1..b6792c5 100644
> --- a/test/shell/lvcreate-raid.sh
> +++ b/test/shell/lvcreate-raid.sh
> @@ -41,7 +41,7 @@ function wait_for_raid_sync()
>   	local i=0
>
>   	while ! is_raid_in_sync $1; do
> -		sleep .2
> +		sleep 1
>   		i=$(($i + 1))
>   		if [ $i -gt 500 ]; then
>   			echo "Sync is taking too long - assume stuck"

I'd prefer to increase the time  5x   i.e.  test $i -gt 2500;

Zdenek


