From: Milan Broz <mbroz@redhat.com>
Date: Fri, 29 Apr 2011 13:21:41 +0200
Subject: [PATCH 2/5] Cast to 'int'
In-Reply-To: <7ef25f300a8bfeda9535d37cb63474bb6b78ac71.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
	<7ef25f300a8bfeda9535d37cb63474bb6b78ac71.1303215346.git.zkabelac@redhat.com>
Message-ID: <4DBA9F45.9060608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/19/2011 02:55 PM, Zdenek Kabelac wrote:

>  #ifdef linux
> -#  define MAJOR(dev)	((dev & 0xfff00) >> 8)
> +#  define MAJOR(dev)	((int)(dev & 0xfff00) >> 8)
>  #  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
>  #  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
>  #else

I we really want to play this cast games (seems I was infected too:-),
please fix all defines to use (int) - like MAJOR() so it is consistent
despite there is no current gcc warning.

Milan
p.s.
or use gnu_dev_major()/minor, it is reliable these days.

