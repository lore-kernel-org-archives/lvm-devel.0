From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 8 Dec 2010 19:21:13 +0000
Subject: LVM2 include/.symlinks.in lib/Makefile.in lib/ ...
In-Reply-To: <4CF61055.3000008@redhat.com>
References: <20101130115336.28589.qmail@sourceware.org>
	<4CF61055.3000008@redhat.com>
Message-ID: <20101208192113.GH27182@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 01, 2010 at 10:07:33AM +0100, Zdenek Kabelac wrote:
> is not defined of fails -  'percent' will contain some garbage.
 
If target_percent is not defined, there is meant to be no affect
on the output.  IOW it should 'continue' as with the tests immediately
above it.

Alasdair


