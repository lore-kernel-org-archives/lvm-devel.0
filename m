From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 7 Jul 2010 19:16:02 +0100
Subject: [PATCH 6/6] Exit status 0 for 'dmsetup -c -o help'
In-Reply-To: <021570bdb0ff125d08c6b92a411fc34a02ef48c2.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
	<021570bdb0ff125d08c6b92a411fc34a02ef48c2.1278505444.git.zkabelac@redhat.com>
Message-ID: <20100707181602.GC22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 07, 2010 at 02:29:36PM +0200, Zdenek Kabelac wrote:
> diff --git a/tools/dmsetup.c b/tools/dmsetup.c
> index 5e71542..479cbb0 100644
> --- a/tools/dmsetup.c
> +++ b/tools/dmsetup.c
> @@ -3340,6 +3340,7 @@ int main(int argc, char **argv)
>  	}
>  
>  	if (argc == 0) {
> +		r = 0;
>  		_usage(stderr);
>  		goto out;

How does that work?

# dmsetup

Should give failure status.
(It already does.)

# dmsetup help

Should give success.
(It already does.)

# dmsetup -c -o help

Should give success.
(It doesn't.)

Alasdair


