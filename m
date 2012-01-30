From: Joe Thornber <thornber@redhat.com>
Date: Mon, 30 Jan 2012 09:43:37 +0000
Subject: [linux-lvm] 答复: New LVM2 release 2.02.89: Thinly-provisioned logical?volumes
In-Reply-To: <A0D9F519724C4648B433C8FA859E3EBB7CD0390C@EX01.sogou-inc.com>
References: <20120127025701.GB16767@agk-dp.fab.redhat.com>
	<A0D9F519724C4648B433C8FA859E3EBB7CD0390C@EX01.sogou-inc.com>
Message-ID: <20120130094336.GA4264@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 30, 2012 at 06:29:54AM +0000, Kirby Zhou wrote:
> Can the thinly-provisioned logical volume automatically return its owned space to the pool?
> I mean, if I create a huge file on the logical volume, then delete it, will the logical volume actual space size be reduced automatically?
> If not, how can it be shrinked?


Discard support is currently in testing.  Should go upstream soon.

- Joe


